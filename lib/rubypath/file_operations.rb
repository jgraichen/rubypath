class Path

  # Return base name without path.
  #
  # @return [String] Base name.
  #
  def name
    ::File.basename internal_path
  end
  alias_method :basename, :name

  # TODO
  def touch(*args)
    with_path(*args) do |path|
      invoke_backend :touch, path
    end
  end
end
