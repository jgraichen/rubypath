class Path

  class << self
    # @!group Construction

    # Create new {Path}.
    #
    # If single argument is a path object it will be returned and no new one
    # will be created. If not arguments are given {Path::EMPTY} will be
    # returned.
    #
    # @see #initialize
    #
    def new(*args)
      args.flatten!
      return Path::EMPTY if args.empty?
      return args.first if args.size == 1 && args.first.is_a?(self)
      super
    end

    # Check if given object is like a path.
    #
    # An object is like a path if
    # 1. It is a {Path} object.
    # 2. It is a string.
    # 3. It responds to {#to_path} and {#to_path} returns a string.
    # 4. It responds to {#path} and {#path} returns a string.
    #
    # If no rule matches it is not considered to be like a path.
    #
    # @return [Boolean] True if object is path like, false otherwise.
    #
    def like?(obj)
      return true if obj.is_a?(self)
      return true if obj.is_a?(String)
      return true if obj.respond_to?(:to_path) && obj.to_path.is_a?(String)
      return true if obj.respond_to?(:path) && obj.path.is_a?(String)
      false
    end

    # Convert given object to path string using {::Path.like?} rules.
    #
    # @note Should not be used directly.
    #
    # @return [String]
    # @raise [ArgumentError] If given object is not {::Path.like?}.
    # @see ::Path.like?
    #
    def like_path(obj)
      case obj
        when String
          return obj
        else
          [:to_path, :path, :to_str, :to_s].each do |mth|
            if obj.respond_to?(mth) && obj.send(mth).is_a?(String)
              return obj.send(mth)
            end
          end
      end

      raise ArgumentError.new \
        "Argument #{obj.inspect} cannot be converted to path string."
    end

    # Return system file path separator.
    #
    # @return [String] File separator.
    # @see ::File::SEPARATOR
    #
    def separator
      ::File::SEPARATOR
    end

    # Allow class object to be used as a bock.
    #
    # @example
    #   %w(path/to/fileA path/to/fileB).map(&Path)
    #
    def to_proc
      proc {|*args| Path.new(*args) }
    end
  end

  # @!group Construction

  # Initialize new {Path} object.
  #
  # Given arguments will be converted to String using `#to_path`, `#path` or
  # `#to_s` in this order if they return a String object.
  #
  # @overload initialize([[String, #to_path, #path, #to_s], ...]
  #
  def initialize(*args)
    parts = args.flatten
    @path = if parts.size > 1
              ::File.join(*parts.map{|p| Path.like_path p })
            elsif parts.size == 1
              Path.like_path(parts.first).dup
            else
              ''
            end
  end

  # Empty path.
  #
  # @return [Path] Empty path.
  #
  EMPTY = Path.new('')
end
