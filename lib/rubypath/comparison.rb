# frozen_string_literal: true
class Path
  # @!group Comparison

  # Compare path to given object. If object is a string, Path or #{Path.like?}
  # they will be compared using the string paths. Otherwise they are assumed
  # as not equal.
  #
  # @param other [Object] Object to compare path with.
  # @return [Boolean] True if object represents same path.
  #
  def eql?(other)
    if other.is_a?(Path)
      cleanpath.internal_path == other.cleanpath.internal_path
    else
      Path.new(other).eql?(self) if Path.like?(other)
    end
  end
  alias == eql?
end
