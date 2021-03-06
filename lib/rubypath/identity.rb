# frozen_string_literal: true

class Path
  # @!group Identity

  # Return path as string. String will be duped before it gets returned and
  # cannot be used to modify the path object.
  #
  # @return [String] Path as string.
  def path
    internal_path.dup
  end
  alias to_path path
  alias to_str path
  alias to_s path

  # Return a useful object string representation.
  #
  # @return [String] Useful object representation
  def inspect
    "<#{self.class.name}:#{internal_path}>"
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
      yield join(*args)
    else
      yield self
    end
  end
end
