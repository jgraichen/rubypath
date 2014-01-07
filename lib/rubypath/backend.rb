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
    end

    attr_accessor :backend
    def initialize
      self.backend = Backend::Sys.new
    end

    def mock
      self.backend = Backend::Mock.new unless Backend::Mock === self.backend
    end

    def unmock
      self.backend = Backend::Sys.new unless Backend::Sys === self.backend
    end

    delegate :expand_path
    delegate :getwd
  end

  require 'rubypath/backend/mock'
  require 'rubypath/backend/sys'
end
