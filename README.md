# Ruby Path

[![Gem Version](https://badge.fury.io/rb/rubypath.svg)](http://badge.fury.io/rb/rubypath)
[![Build Status](http://img.shields.io/travis/jgraichen/rubypath/master.svg)](https://travis-ci.org/jgraichen/rubypath)
[![Coverage Status](http://img.shields.io/coveralls/jgraichen/rubypath/master.svg)](https://coveralls.io/r/jgraichen/rubypath)
[![Dependency Status](http://img.shields.io/gemnasium/jgraichen/rubypath.svg)](https://gemnasium.com/jgraichen/rubypath)
[![RubyDoc Documentation](http://img.shields.io/badge/rubydoc-here-blue.svg)](http://rubydoc.info/github/jgraichen/rubypath/master/frames)

*Ruby Path* introduces a global `Path` class unifying most `File`, `Dir`, `FileUtils`, `Pathname` and `IO` operations with a flexible and powerful Object-Interface and still adding new useful methods and functions like mocking a while file system for fast and reliable testing.

## Installation

Add `rubypath` to your Gemfile, `gemspec` or install manually.

## Usage

Using `Path` with file and directory methods:

```ruby
base = Path '/path/to/base'
src  = base.mkpath 'project/src'
src.touch 'Rakefile'
src.mkdir('lib').mkdir('mylib').touch('version.rb')
#=> <Path '/path/to/base/project/src/lib/mylib/version.rb'
```

Using IO:

```ruby
src.write "module Mylib\n  VERSION = '0.1.0'\nend"

src.lookup('project.yml').read
#=> "..."
```

### Mock FS in tests

Wrap specific or just all specs in a virtual filesystem:

```ruby
# spec_helper.rb

config.around(:each) do |example|
  Path::Backend.mock root: :tmp, &example
end
```

Supported options for `:root` are `:tmp` using the real filesystem but scoping all actions into a temporary directory similar to chroot or a custom defined path to use as "chroot" directory. This mode does not allow to stub users, home directories and some attributes.

If not `:root` is specified a completely virtual in-memory filesystem will be used. This backend allows to even specify available users and home directories, the current user etc.

You can then define a specific scenario in your specs:

```ruby
    before do
      Path.mock do |root, backend|
        backend.cwd          = '/root'
        backend.current_user = 'test'
        backend.homes        = {'test' => '/home/test'}

        home = root.mkpath('/home/test')
        home.mkfile('src/test.txt').write 'CONTENT'
        home.mkfile('src/test.html').write '<html><head><title></title>...'
      end
    end

    it 'should mock all FS' do
      base = Path('~test').expand
      expect(base.join(%w(src test.txt)).read).to eq 'CONTENT'

      files = base.glob('**/*').select{|p| p.file? }
      expect(files.size).to eq 2
    end
```

See full API documentation here: http://rubydoc.info/gems/rubypath/Path

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add specs testing SYS *and* MOCK file system
4. Commit your specs (`git commit -am 'Add specs for feature'`)
5. Add our changes for SYS *and* MOCK file system
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create new Pull Request

### ToDos

* Add missing methods
* Improve MOCK FS implementation

## License

Copyright (C) 2014 Jan Graichen

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
