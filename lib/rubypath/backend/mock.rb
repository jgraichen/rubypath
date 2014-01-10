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
        file.mtime   = DateTime.now
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

    def read(path, *args)
      content = lookup_file!(path).content
      if args[0]
        length = args[0].to_i
        offset = args[1] ? args[1].to_i : 0
        content = content.slice(offset, length)
      end
      content
    end

    def entries(path)
      node = lookup_dir! path
      node.children.map(&:name) + %w(. ..)
    end

    #@!group Internal Virtual File System

    # Return root node.
    def root
      @root ||= Dir.new(self, '')
    end

    def lookup(path)
      path = expand_path(path)
      path = path[1..-1] if path[0] == '/'

      self.root.lookup path
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
      if (node = lookup ::File.dirname expand_path path)
        if Dir === node
          return node
        else
          raise Errno::ENOTDIR.new path
        end
      end
      raise Errno::ENOENT.new path
    end

    class Node
      attr_reader :sys, :name, :parent
      attr_accessor :mtime

      def initialize(backend, name)
        @sys   = backend
        @name  = name
        @mtime = Time.now
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
        name, rest = path.split('/', 2).map(&:to_s)

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
