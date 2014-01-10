class Path
  #@!group IO Operations

  # TODO
  def write(content)
    invoke_backend :write, internal_path, content
  end

  # TODO
  def read
    invoke_backend :read
  end
end
