class Path::Backend

  #
  class Sys

    def initialize(root = nil)
      @root  = ::File.expand_path root if root
      @umask = File.umask
    end

    def quit
      File.umask @umask
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

    def ur(path)
      return path unless @root

      if path.slice(0, @root.length) == @root
        path.slice(@root.length, path.length - @root.length)
      else
        path
      end
    end

    def fs(path, obj, method, *args)
      # puts "[FS] #{obj} #{method} #{args.inspect}"
      obj.send method, *args
    rescue Errno::ENOENT
      raise Errno::ENOENT.new path
    rescue Errno::EISDIR
      raise Errno::EISDIR.new path
    rescue Errno::ENOTDIR
      raise Errno::ENOTDIR.new path
    rescue Errno::EACCES
      raise Errno::EACCES.new path
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

    def atime=(path, time)
      fs path, ::File, :utime, time, mtime(path), r(path)
    end

    def entries(path)
      fs path, ::Dir, :entries, r(path)
    end

    def glob(pattern, flags = 0, &block)
      if block_given?
        fs pattern, ::Dir, :glob, r(pattern), flags do |path|
          yield ur(path)
        end
      else
        fs(pattern, ::Dir, :glob, r(pattern), flags).map{|path| ur path }
      end
    end

    def get_umask
      File.umask
    end

    def set_umask(mask)
      File.umask mask
    end

    def mode(path)
      fs(path, ::File, :stat, r(path)).mode & 0777
    end

    def chmod(path, mode)
      fs path, ::File, :chmod, mode, r(path)
    end

    def unlink(path)
      fs path, ::File, :unlink, r(path)
    end
  end
end
