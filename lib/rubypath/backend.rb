class Path
  class Backend
    class << self
      def instance
        @instance ||= self.new
      end

      def delegate(mth)
        define_method mth do |*args|
          backend.send mth, *args
        end
      end

      def mock(*args, &block)
        self.instance.mock *args, &block
      end
    end

    attr_accessor :backend
    def initialize
      self.backend = Backend::Sys.new
    end

    def mock(opts = {}, &block)
      if opts[:root]
        # Use real file system scoped to given directory (chroot like)
        if opts[:root] == :tmp
          ::Dir.mktmpdir('rubypath') do |path|
            use_backend Backend::Sys.new(path), &block
          end
        else
          use_backend Backend::Sys.new(opts[:root]), &block
        end
      else
        # Use mock FS
        use_backend Backend::Mock.new, &block
      end
    end

    def use_backend(be)
      old_backend, self.backend = self.backend, be
      yield
      self.backend = old_backend
    end

    delegate :expand_path
    delegate :getwd
    delegate :exists?
    delegate :mkdir
    delegate :mkpath
    delegate :directory?
    delegate :file?
    delegate :touch
    delegate :write
    delegate :read
    delegate :mtime
    delegate :mtime=
    delegate :entries
    delegate :glob
  end

  private
  def invoke_backend(mth, *args)
    args << self if args.empty?
    Backend.instance.send mth, *args
  end

  require 'rubypath/backend/mock'
  require 'rubypath/backend/sys'
end
