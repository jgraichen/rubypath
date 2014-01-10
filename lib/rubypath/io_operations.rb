class Path
  #@!group IO Operations

  # TODO
  def write(content, *args)
    invoke_backend :write, internal_path, content, *args
  end

  # TODO
  def read(*args)
    invoke_backend :read, internal_path, *args
  end
end
