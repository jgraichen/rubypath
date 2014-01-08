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
      path = expand_path(path)
      node = self.lookup(::File.dirname(path))
      raise Errno::ENOENT.new "No such file or directory - #{path}" unless node
      node.children << Dir.new(self, ::File.basename(path))
    end

    def mkpath(path)
      path = expand_path(path)
      ::Pathname.new(path).descend do |path|
        mkdir(path.to_s)
      end
    end

    def touch(path)
      node = self.lookup(::File.dirname(path))
      raise Errno::ENOENT.new "No such file or directory - #{path}" unless node
      node.children << File.new(self, ::File.basename(path))
    end

    #@!group Internal Virtual File System

    # Return root node.
    def root
      @root ||= Dir.new(self, '/')
    end

    def lookup(path)
      path = expand_path(path)
      path = path[1..-1] if path[0] == '/'

      self.root.lookup path
    end

    class Node
      attr_reader :sys, :name
      def initialize(backend, name)
        @sys  = backend
        @name = name
      end

      def lookup(path)
        raise NotImplementError.new 'Subclass responsibility.'
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

      def children
        @children ||= []
      end
    end

    class File < Node
      def lookup(path)
        nil
      end
    end
  end
end
