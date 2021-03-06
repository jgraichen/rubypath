# frozen_string_literal: true

class Path
  class Backend
    class << self
      def instance
        @instance ||= new
      end

      def delegate(mth)
        define_method mth do |*args|
          backend.send mth, *args
        end
      end

      def mock(*args, &block)
        instance.mock(*args, &block)
      end
    end

    attr_accessor :backend
    def initialize
      self.backend = Backend::Sys.new
    end

    # rubocop:disable Metrics/MethodLength
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
    # rubocop:enable Metrics/MethodLength

    def use_backend(be)
      old_backend = backend
      self.backend = be
      yield
      backend.quit if backend.respond_to? :quit
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
    delegate :atime
    delegate :atime=
    delegate :umask
    delegate :umask=
    delegate :mode
    delegate :chmod
    delegate :unlink
    delegate :rmtree
    delegate :rmtree!
    delegate :safe_rmtree
    delegate :safe_rmtree!
  end

  private

  def invoke_backend(mth, *args)
    args << self if args.empty?
    self.class.send :invoke_backend, mth, *args
  end

  class << self
    private

    def invoke_backend(mth, *args)
      Backend.instance.send mth, *args
    end
  end

  require 'rubypath/backend/mock'
  require 'rubypath/backend/sys'
end
