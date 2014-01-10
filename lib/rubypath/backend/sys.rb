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

    def fs(path, obj, method, *args)
      # puts "[FS] #{obj} #{method} #{args.inspect}"
      obj.send method, *args
    rescue Errno::ENOENT => ex
      raise Errno::ENOENT.new path
    rescue Errno::EISDIR => ex
      raise Errno::EISDIR.new path
    rescue Errno::ENOTDIR => ex
      raise Errno::ENOTDIR.new path
    end

    ## OPERATIONS

    def expand_path(path, base)
      ::File.expand_path path, base
    end

    def exists?(path)
      fs path, ::File, :exists?, r(path)
    end

    def mkdir(path)
      fs path, ::Dir, :mkdir, r(path)
    end

    def mkpath(path)
      fs path, ::FileUtils, :mkdir_p, r(path)
    end

    def directory?(path)
      fs path, ::File, :directory?, r(path)
    end

    def file?(path)
      fs path, ::File, :file?, r(path)
    end

    def touch(path)
      fs path, ::FileUtils, :touch, r(path)
    end

    def write(path, content, *args)
      fs path, ::IO, :write, r(path), content, *args
    end

    def read(path, *args)
      fs path, ::IO, :read, r(path), *args
    end

    def mtime(path)
      fs path, ::File, :mtime, r(path)
    end

    def mtime=(path, time)
      fs path, ::File, :utime, atime(path), time, r(path)
    end

    def atime(path)
      fs path, ::File, :atime, r(path)
    end

    def entries(path)
      fs path, ::Dir, :entries, r(path)
    end
  end
end
