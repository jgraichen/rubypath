class Path
  # @!group Identity

  # Return path as string. String will be duped before it gets returned and
  # cannot be used to modify the path object.
  #
  # @return [String] Path as string.
  def path
    internal_path.dup
  end
  alias_method :to_path, :path
  alias_method :to_s, :path

  # Return a useful object string representation.
  #
  # @return [String] Useful object representation
  def inspect
    "<#{self.class.name}:#{object_id} #{path.inspect}>"
  end



  protected

  # Return internal path object without duping.
  #
  # Must not be modified to not change internal state.
  #
  # @return [String] Internal path.
  # @see #path
  #
  def internal_path
    @path
  end

  # If arguments are provided the current path will be joined with given
  # arguments to the result will be yielded. If no arguments are given the
  # current path will be yielded.
  #
  # Internal helper method.
  #
  # @example
  #   def handle_both(*args)
  #     with_path(*args) do |path|
  #       # do something
  #     end
  #   end
  #
  # Returns whatever the block returns.
  #
  def with_path(*args)
    if args.any?
      yield join(*args).internal_path
    else
      yield internal_path
    end
  end
end
