# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubypath/version'

Gem::Specification.new do |spec|
  spec.name          = "rubypath"
  spec.version       = Path::VERSION
  spec.authors       = ["Jan Graichen"]
  spec.email         = ["jg@altimos.de"]
  spec.description   = %q{Path library incorporating File, Dir, Pathname, IO methods as well as a virtual mock filesystem.}
  spec.summary       = %q{Path library incorporating File, Dir, Pathname, IO methods as well as a virtual mock filesystem.}
  spec.homepage      = "https://github.com/jgraichen/rubypath"
  spec.license       = "LGPLv3"

  spec.files         = Dir['**/*'].grep(%r{^((bin|lib|test|spec|features)/|.*\.gemspec|.*LICENSE.*|.*README.*|.*CHANGELOG.*)})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
end
