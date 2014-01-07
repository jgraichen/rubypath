require 'spec_helper'

describe Path do
  describe 'Path Operations' do
    let(:str)  { '/root/path' }
    let(:args) { [str] }
    let(:path) { Path(*args) }
    subject { path }

    describe '#join' do
      subject { path.join *join_args}

      context 'with single string' do
        let(:join_args) { ['to/file.txt'] }
        it { should eq '/root/path/to/file.txt' }
      end

      context 'with multiple strings' do
        let(:join_args) { ['to/', 'file.txt'] }
        it { should eq '/root/path/to/file.txt' }
      end

      context 'with multiple args' do
        let(:join_args) { ['to/', Path('dir'), Pathname.new('sub/file.txt')] }
        it { should eq '/root/path/to/dir/sub/file.txt' }
      end

      context 'with absolute path' do
        let(:join_args) { ['/path/to/file.txt'] }
        it { should eq '/path/to/file.txt' }
      end

      context 'with mixed paths' do
        let(:join_args) { ['rel/file', '/path/to/file.txt', 'sub'] }
        it { should eq '/path/to/file.txt/sub' }
      end
    end

    # describe ".lookup" do
    #   before(:all) do
    #     Path.mock do |r|
    #       r.mkpath 'a/b/c/d'
    #       r.touch 'a/test.txt'
    #       r.touch 'a/b/c/config.yaml'
    #       r.touch 'a/config.yml'
    #     end
    #   end
    #   after { Path.unmock }
    #   let(:path) { Path('/') }

    #   context "with filename" do
    #     it "should find file in current directory" do
    #       expect(path.join('a').lookup("test.txt")).to eq fixture_path '/a/test.txt'
    #     end

    #     it "should find file in parent directory" do
    #       expect(path.join(%w(a b)).lookup("test.txt")).to eq fixture_path '/a/test.txt'
    #     end

    #     it "should find file in ancestor directory" do
    #       expect(path.join("a/b/c/d").lookup("test.txt")).to eq fixture_path '/a/test.txt'
    #     end

    #     it "should find first file in ancestor directory" do
    #       expect(path.join("a/b/c/d").lookup("config.yaml")).to eq fixture_path '/a/b/c/config.yaml'
    #     end
    #   end

    #   context "with glob" do
    #     it "should find file in current directory" do
    #       expect(path.join('a').lookup('test.*')).to eq fixture_path '/a/test.txt'
    #     end

    #     it "should find file in parent directory" do
    #       expect(path.join("a/b").lookup('test.*')).to eq fixture_path '/a/test.txt'
    #     end

    #     it "should find file in ancestor directory" do
    #       expect(path.join("a/b/c/d").lookup('test.*')).to eq fixture_path '/a/test.txt'
    #     end

    #     it "should find first file in ancestor directory" do
    #       expect(path.join("a/b/c/d").lookup('config.*')).to eq fixture_path '/a/b/c/config.yaml'
    #     end

    #     it "should find first file that match" do
    #       expect(path.join("a/b").lookup('*.yml')).to eq fixture_path '/a/config.yml'
    #     end
    #   end

    #   context "with regexp" do
    #     it "should find file in current directory" do
    #       expect(path.join('a').lookup(/^test\.txt$/)).to eq fixture_path '/a/test.txt'
    #     end

    #     it "should find file in parent directory" do
    #       expect(path.join("a/b").lookup(/^test\.txt$/)).to eq fixture_path '/a/test.txt'
    #     end

    #     it "should find file in ancestor directory" do
    #       expect(path.join("a/b/c/d").lookup(/^test\.txt$/)).to eq fixture_path '/a/test.txt'
    #     end

    #     it "should find first file in ancestor directory" do
    #       expect(path.join("a/b/c/d").lookup(/^config\.yaml$/)).to eq fixture_path '/a/b/c/config.yaml'
    #     end

    #     it "should find first file that match" do
    #       expect(path.join("a/b").lookup(/^config\.ya?ml$/)).to eq fixture_path '/a/config.yml'
    #     end
    #   end
    # end

    [:dir, :dirname, :parent].each do |mth|
      describe "##{mth}" do
        context 'with absolute path' do
          it 'should return parent directory' do
            expect(Path('/path/to/file').dir).to eq '/path/to'
          end

          context 'when hitting root' do
            it 'should return root' do
              expect(Path('/path').dir).to eq '/'
            end
          end

          context 'when being root' do
            it 'should return nil' do
              expect(Path('/').dir).to eq nil
            end
          end
        end

        context 'with relative path' do
          it 'should return parent directory' do
            expect(Path('path/to/file').dir).to eq 'path/to'
          end

          context 'when hitting root' do
            it 'should return current path' do
              expect(Path('path').dir).to eq '.'
            end
          end

          context 'when being root' do
            it 'should return nil' do
              expect(Path('.').dir).to eq nil
            end
          end
        end
      end
    end

    describe "#expand" do
      let(:path) { Path('~/tmp') }

      before do
        Path.mock do |root, back|
          back.current_user = 'test'
          back.homes = {'test' => '/home/test'}
        end
      end
      after { Path.unmock }

      context 'w/o args' do
        it 'should invoke backend with current path' do
          expect(Path::Backend.instance).to receive(:expand_path).with('~/tmp', '/').and_call_original
          expect(path.expand).to eq '/home/test/tmp'
        end

        context 'with base option' do
          let(:path) { Path('./tmp') }

          it 'should pass base directory to backend' do
            expect(Path::Backend.instance).to receive(:expand_path).with('./tmp', '/abc').and_call_original
            expect(path.expand(base: '/abc')).to eq '/abc/tmp'
          end
        end
      end

      context 'with args' do
        it 'should invoke backend with joined path' do
          expect(Path::Backend.instance).to receive(:expand_path).with('~/tmp/fuu', '/').and_call_original
          expect(path.expand('fuu')).to eq '/home/test/tmp/fuu'
        end

        context 'with base option' do
          let(:path) { Path('./tmp') }

          it 'should pass base directory to backend' do
            expect(Path::Backend.instance).to receive(:expand_path).with('./tmp/fuu', '/abc').and_call_original
            expect(path.expand('fuu', base: '/abc')).to eq '/abc/tmp/fuu'
          end
        end
      end
    end
  end
end
