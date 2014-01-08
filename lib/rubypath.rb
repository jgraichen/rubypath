require "rubypath/version"

#
#
#
class Path
  require 'rubypath/identity'
  require 'rubypath/construction'
  require 'rubypath/comparison'
  require 'rubypath/extensions'

  require 'rubypath/path_operations'
  require 'rubypath/path_predicates'
  require 'rubypath/file_operations'
  require 'rubypath/dir_operations'

  require 'rubypath/mock'
  require 'rubypath/backend'

end

module Kernel
  def Path(*args)
    Path.new *args
  end
end
