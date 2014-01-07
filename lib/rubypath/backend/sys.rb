class Path::Backend

  class Sys

    def home(user)
      ::File.expand_path "~#{user}"
    end

    def getwd
      ::Dir.getwd
    end

    def expand_path(path, base)
      ::File.expand_path path, base
    end

    def user
      require 'etc'

      Etc.getlogin
    end
  end
end
