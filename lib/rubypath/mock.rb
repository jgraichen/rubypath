class Path
  class << self
    #@!group Mocking / Virtual File System

    # Operate on current path backend. Can be used to configure specified
    # test scenario. If no virtual or scoped path backend set the default one
    # will be used.
    #
    # Do not forget to set your path backend in test helper.
    # See more {Backend.mock}.
    #
    #     around do |example|
    #       Path::Backend.mock &example
    #     end
    #
    # *Note*: Not all operations are supported.
    #
    # @example
    #   Path.mock do |root|
    #     root.mkpath '/a/b/c/d/e'
    #     root.touch '/a/b/test.txt'
    #     root.join('/a/c/lorem.yaml').write YAML.dump({'lorem' => 'ipsum'})
    #     #...
    #   end
    #
    # @example Configure backend (only with virtual file system)
    #   Path.mock do |root, backend|
    #     backend.current_user = 'test'
    #     backend.homes = {'test' => '/path/to/test/home'}
    #     #...
    #   end
    #
    def mock(opts = {})
      yield Path('/'), Backend.instance.backend if block_given?
      nil
    end
  end
end
