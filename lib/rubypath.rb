require "rubypath/version"

#
#
#
class Path
  require 'rubypath/identity'
  require 'rubypath/construction'
  require 'rubypath/comparison'
  require 'rubypath/path_operations'
  require 'rubypath/path_predicates'
  require 'rubypath/dir_operations'

  require 'rubypath/mock'
  require 'rubypath/backend'

end

module Kernel
  def Path(*args)
    Path.new *args
  end
end
