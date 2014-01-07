class Path
  class << self
    #@!group Mocking / Virtual File System

    # Mock the complete file system. All operations are mocked within a
    # virtual file system until {.unmock} is called.
    #
    # *Note*: Not all operations are supported.
    #
    # If a block is passed the root node will be yielded to allow simple
    # creation of mock file systems.
    #
    # @example
    #   Path.mock do |root|
    #     root.mkpath '/a/b/c/d/e'
    #     root.touch '/a/b/test.txt'
    #     root.write '/a/c/lorem.yaml', YAML.dump({'lorem' => 'ipsum'})
    #   end
    #
    # @see #unmock
    #
    def mock
      Backend.instance.mock

      yield Path('/'), Backend.instance.backend if block_given?

      nil
    end

    # Disable virtual mock file system.
    #
    # @see #mock
    #
    def unmock
      Backend.instance.unmock
      nil
    end
  end
end
