class Path::Backend

  class Mock
    attr_reader :user, :homes

    #@!group Virtual File System Configuration

    # Set user that owns the current process.
    def current_user=(user)
      @user = user.to_s
    end

    # Define new home directories. Must be given as has a hash that is
    # interpreted as a user name to home directory mapping.
    def homes=(homes)
      @homes = homes
    end

    # Set current working directory.
    def cwd=(cwd)
      @cwd = cwd
    end

    #@!group Internal Methods

    def initialize
      @user  = 'root'
      @homes = {'root' => '/root'}
      @cwd   = '/root'
      @umask = 0022
    end

    def home(user)
      self.homes[user] or raise ArgumentError.new("user #{user} doesn't exist")
    end

    #@!group Backend Operations

    def expand_path(path, base = getwd)
      if /^~(?<name>[^\/]*)(\/(?<rest>.*))?$/ =~ path
        ::File.expand_path rest.to_s, self.home(name.empty? ? self.user : name)
      else
        ::File.expand_path(path, base)
      end
    end
    alias_method :expand, :expand_path

    def getwd
      @cwd ||= '/'
    end

    def file?(path)
      File === self.lookup(path)
    end

    def directory?(path)
      Dir === self.lookup(path)
    end

    def exists?(path)
      !!self.lookup(path)
    end

    def mkdir(path)
      return if path.to_s == '/'

      node = lookup_parent! path
      dir  = node.lookup ::File.basename path
      unless Dir === dir
        if dir.nil?
          node.add Dir.new(self, ::File.basename(path))
        else
          raise ArgumentError.new "Node #{dir.path} exists and is no directory."
        end
      end
    end

    def mkpath(path)
      path = expand_path(path)
      ::Pathname.new(path).descend do |path|
        mkdir(path.to_s)
      end
    end

    def touch(path)
      node = lookup_parent! path
      file = node.lookup ::File.basename path
      if file
        file.mtime = Time.now
      else
        node.add File.new(self, ::File.basename(path))
      end
    end

    def write(path, content, *args)
      node = lookup_parent! path
      file = node.lookup ::File.basename(path)
      unless file
        file = File.new self, ::File.basename(path)
        node.add file
      end

      case file
      when File
        if args.empty?
          file.content = content
        else
          offset = args[0].to_i
          file.content[offset, content.length] = content
        end
        file.mtime   = Time.now
      when Dir
        raise Errno::EISDIR.new path
      else
        raise ArgumentError.new
      end
    end

    def mtime(path)
      lookup!(path).mtime
    end

    def mtime=(path, time)
      lookup!(path).mtime = time
    end

    def atime(path)
      lookup!(path).atime
    end

    def atime=(path, time)
      lookup!(path).atime = time
    end

    def read(path, *args)
      file       = lookup_file!(path)
      file.atime = Time.now
      content    = file.content
      if args[0]
        length  = args[0].to_i
        offset  = args[1] ? args[1].to_i : 0
        content = content.slice(offset, length)
      end
      content
    end

    def entries(path)
      node = lookup_dir! path
      node.children.map(&:name) + %w(. ..)
    end

    def glob(pattern, flags = 0, &block)
      self.root.all.select do |node|
        ::File.fnmatch pattern, node.path, (flags | ::File::FNM_PATHNAME)
      end
    end

    def get_umask
      @umask
    end

    def set_umask(mask)
      @umask = Integer(mask)
    end

    #@!group Internal Virtual File System

    # Return root node.
    def root
      @root ||= Dir.new(self, '')
    end

    def to_lookup(path)
      path = expand path
      path.sub /^\/+/, ''
    end

    def lookup(path)
      self.root.lookup to_lookup path
    end

    def lookup!(path)
      if (node = lookup(path))
        node
      else
        raise Errno::ENOENT.new path
      end
    end

    def lookup_file!(path)
      node = lookup! path
      case node
      when File
        node
      when Dir
        raise Errno::EISDIR.new path
      else
        raise ArgumentError.new "NOT A FILE: #{path}"
      end
    end

    def lookup_dir!(path)
      if Dir === (node = lookup!(path))
        node
      else
        raise Errno::ENOENT.new path
      end
    end

    def lookup_parent!(path)
      node = lookup ::File.dirname expand path
      if node
        Dir === node ? node : raise(Errno::ENOTDIR.new path)
      else
        raise Errno::ENOENT.new path
      end
    end

    class Node
      attr_reader :sys, :name, :parent
      attr_accessor :mtime, :atime

      def initialize(backend, name)
        @sys   = backend
        @name  = name
        @mtime = Time.now
        @atime = Time.now
      end

      def mtime=(time)
        raise "Not Time but `#{time.inspect}` of `#{time.class.name}` given." unless Time === time
        @mtime = time
      end

      def lookup(path)
        raise NotImplementError.new 'Subclass responsibility.'
      end

      def added(parent)
        @parent = parent
      end

      def path
        parent ? "#{parent.path}/#{name}" : name
      end
    end

    class Dir < Node
      def lookup(path)
        name, rest = path.to_s.split('/', 2).map(&:to_s)

        if name.nil?
          if rest.nil?
            self
          else
            lookup rest
          end
        else
          if (child = children.find{|c| c.name == name })
            rest.nil? ? child : child.lookup(rest)
          else
            nil
          end
        end
      end

      def add(node)
        raise ArgumentError.new "Node #{path}/#{node.name} already exists." if children.any?{|c| c.name == node.name}
        children << node
        node.added self
      end

      def all
        children.inject([]) do |memo, child|
          memo << child
          memo += child.all if Dir === child
          memo
        end
      end

      def children
        @children ||= []
      end
    end

    class File < Node
      attr_accessor :content

      def initialize(*args)
        super
      end

      def lookup(path)
        nil
      end
    end
  end
end
