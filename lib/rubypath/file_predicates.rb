class Path

  # TODO
  def file?
    invoke_backend :file?
  end

  # TODO
  def exists?
    invoke_backend :exists?
  end
  alias_method :exist?, :exists?
  alias_method :existent?, :exists?

  # TODO
  def directory?
    invoke_backend :directory?
  end
  alias_method :dir?, :directory?
end
