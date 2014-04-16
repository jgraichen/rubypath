require 'spec_helper'

describe 'README examples' do
  describe 'Mock FS' do
    around {|example| Path::Backend.mock(&example) }

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
  end
end
