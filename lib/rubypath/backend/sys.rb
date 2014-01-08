class Path::Backend

  class Sys

    def initialize(root = nil)
      @root = root
    end

    def home(user)
      ::File.expand_path "~#{user}"
    end

    def getwd
      ::Dir.getwd
    end

    def user
      require 'etc'

      Etc.getlogin
    end

    def r(path)
      return path unless @root
      ::File.expand_path("#{@root}/#{::File.expand_path(path)}")
    end

    def access_fs(obj, method, *args)
      #puts "[ACCESS FS] #{obj} #{method} #{args.inspect}"
      obj.send method, *args
    end

    ## OPERATIONS

    def expand_path(path, base)
      ::File.expand_path path, base
    end

    def exists?(path)
      access_fs ::File, :exists?, r(path)
    end

    def mkdir(path)
      access_fs ::Dir, :mkdir, r(path)
    end

    def mkpath(path)
      access_fs ::FileUtils, :mkdir_p, r(path)
    end

    def directory?(path)
      access_fs ::File, :directory?, r(path)
    end

    def file?(path)
      access_fs ::File, :file?, r(path)
    end

    def touch(path)
      access_fs ::FileUtils, :touch, r(path)
    end
  end
end
