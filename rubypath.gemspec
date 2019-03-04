# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubypath/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubypath'
  spec.version       = Path::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = ['jg@altimos.de']
  spec.description   = 'Path library incorporating File, Dir, Pathname, IO ' \
                       'methods as well as a virtual mock filesystem.'
  spec.summary       = 'Path library incorporating File, Dir, Pathname, IO ' \
                       'methods as well as a virtual mock filesystem.'
  spec.homepage      = 'https://github.com/jgraichen/rubypath'
  spec.license       = 'LGPL-3.0+'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match %r{
      ^(lib)/
      |CHANGELOG.*
      |LICENSE.*
      |.*\.gemspec
    }ix
  end
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
end
