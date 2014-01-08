class Path::Backend

  class Mock

    attr_reader :user, :homes

    # Mock Configuration

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


    # INIT
    def initialize
      @user  = 'root'
      @homes = {'root' => '/root'}
      @cwd   = '/root'
    end

    # OPERATIONS
    def home(user)
      self.homes[user] or raise ArgumentError.new("user #{user} doesn't exist")
    end

    def expand_path(path, base)
      if /^~(?<name>[^\/]*)(\/(?<rest>.*))?$/ =~ path
        ::File.expand_path rest.to_s, self.home(name.empty? ? self.user : name)
      else
        ::File.expand_path(path, base)
      end
    end

    def getwd
      @cwd ||= '/'
    end
  end
end
