# frozen_string_literal: true
class Path::Backend
  class Mock
    attr_reader :user, :homes

    # @!group Virtual File System Configuration

    # Set user that owns the current process.
    def current_user=(user)
      @user = user.to_s
    end

    # Define new home directories. Must be given as has a hash that is
    # interpreted as a user name to home directory mapping.
    attr_writer :homes

    # Set current working directory.
    attr_writer :cwd

    # @!group Internal Methods

    def initialize
      @user  = 'root'
      @homes = {'root' => '/root'}
      @cwd   = '/root'
      @umask = 0o022
    end

    def home(user)
      homes.fetch(user) { raise ArgumentError.new "user #{user} doesn't exist" }
    end

    # @!group Backend Operations

    def expand_path(path, base = getwd)
      if %r{^~(?<name>[^/]*)(/(?<rest>.*))?$} =~ path
        ::File.expand_path rest.to_s, home(name.empty? ? user : name)
      else
        ::File.expand_path(path, base)
      end
    end
    alias expand expand_path

    def getwd
      @cwd ||= '/'
    end

    def file?(path)
      lookup(path).is_a?(File)
    end

    def directory?(path)
      lookup(path).is_a?(Dir)
    end

    def exists?(path)
      lookup(path) ? true : false
    end

    def mkdir(path)
      return if path.to_s == '/'

      node = lookup_parent! path
      dir  = node.lookup ::File.basename path
      unless dir.is_a?(Dir)
        if dir.nil?
          node.add Dir.new(self, ::File.basename(path))
        else
          raise ArgumentError.new \
            "Node #{dir.path} exists and is no directory."
        end
      end
    end

    def mkpath(path)
      path = expand_path(path)
      ::Pathname.new(path).descend do |p|
        mkdir(p.to_s)
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
            file.content = String.new(content)
          else
            offset = args[0].to_i
            file.content[offset, content.length] = content
          end
          file.mtime = Time.now
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

    def glob(pattern, flags = 0)
      root.all.select do |node|
        ::File.fnmatch pattern, node.path, (flags | ::File::FNM_PATHNAME)
      end
    end

    def get_umask
      @umask
    end

    def set_umask(mask)
      @umask = Integer(mask)
    end

    def mode(path)
      lookup!(path).mode
    end

    def unlink(path)
      node = lookup_parent!(path)
      file = node.lookup ::File.basename path
      case file
        when Dir
          raise Errno::EISDIR.new path
        when File
          node.children.delete(file)
        when nil
          raise Errno::ENOENT.new path
        else
          raise ArgumentError.new "Unknown node #{node.inspect} for #unlink."
      end
    end

    def rmtree(path)
      node = lookup path
      case node
        when Dir, File
          lookup_parent!(path).children.delete(node)
        when nil
          nil
        else
          raise ArgumentError.new "Unknown node #{node.inspect} for #rmtree."
      end
    end
    alias safe_rmtree rmtree

    def rmtree!(path)
      node = lookup path
      case node
        when Dir, File
          lookup_parent!(path).children.delete(node)
        when nil
          raise Errno::ENOENT.new path
        else
          raise ArgumentError.new "Unknown node #{node.inspect} for #rmtree."
      end
    end
    alias safe_rmtree! rmtree!

    # @!group Internal Virtual File System

    # Return root node.
    def root
      @root ||= Dir.new(self, '')
    end

    def to_lookup(path)
      path = expand path
      path.sub(/^\/+/, '')
    end

    def lookup(path)
      root.lookup to_lookup path
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
      if (node = lookup!(path)).is_a?(Dir)
        node
      else
        raise Errno::ENOENT.new path
      end
    end

    def lookup_parent!(path)
      node = lookup ::File.dirname expand path
      if node
        node.is_a?(Dir) ? node : raise(Errno::ENOTDIR.new(path))
      else
        raise Errno::ENOENT.new path
      end
    end

    #
    class Node
      attr_reader :sys, :name, :parent
      attr_accessor :mtime, :atime, :mode

      def initialize(backend, name, _ops = {})
        @sys   = backend
        @name  = name
        @mtime = Time.now
        @atime = Time.now
      end

      def mtime=(time)
        if time.is_a?(Time)
          @mtime = time
        else
          raise "Not Time but `#{time.inspect}` of `#{time.class.name}` given."
        end
      end

      def lookup(_path)
        raise NotImplementError.new 'Subclass responsibility.'
      end

      def added(parent)
        @parent = parent
      end

      def path
        parent ? "#{parent.path}/#{name}" : name
      end
    end

    #
    class Dir < Node
      def initialize(backend, name, opts = {})
        super
        self.mode = 0o777 - backend.get_umask
      end

      def lookup(path)
        name, rest = path.to_s.split('/', 2).map(&:to_s)

        if name.nil?
          if rest.nil?
            self
          else
            lookup rest
          end
        else
          child = children.find {|c| c.name == name }
          if child
            rest.nil? ? child : child.lookup(rest)
          end
        end
      end

      def add(node)
        if children.any? {|c| c.name == node.name }
          raise ArgumentError.new "Node #{path}/#{node.name} already exists."
        else
          children << node
          node.added self
        end
      end

      def all
        children.reduce([]) do |memo, child|
          memo << child
          memo += child.all if child.is_a?(Dir)
          memo
        end
      end

      def children
        @children ||= []
      end
    end

    #
    class File < Node
      attr_accessor :content

      def initialize(backend, name, opts = {})
        super
        self.mode = 0o666 - backend.get_umask
      end

      def lookup(_path)
        nil
      end
    end
  end
end
