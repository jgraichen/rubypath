class Path
  #@!group Comparison

  # Compare path to given object. If object is a string, Path or #{Path.like?}
  # they will be compared using the string paths. Otherwise they are assumed
  # as not equal.
  #
  # @param other [Object] Object to compare path with.
  # @return [Boolean] True if object represents same path.
  #
  def eql?(other)
    case other
    when String
      internal_path.eql? other
    when Path
      internal_path.eql? other.path
    else
      Path.new(other).eql?(self) if Path.like? other
    end
  end
  alias_method :==, :eql?
end
