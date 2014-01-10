require 'spec_helper'

describe Path do
  describe 'File Operations' do
    with_backends :mock, :sys do
      let(:path) { Path('/path/to/file.txt') }

      describe_method :name, aliases: [:basename] do
        subject { path.send described_method }

        it 'should return file name' do
          should eq 'file.txt'
        end
      end

      describe_method :touch do
        let(:path) { Path '/rubypath' }
        let(:args) { Array.new }
        subject { path.touch *args }
        before { expect(path).to_not be_existent }

        it 'should create file' do
          subject
          expect(path).to be_existent
        end

        it 'should update modification time' do
          subject
          expect(path.mtime).to be_within(1).of(Time.now)
        end

        context 'with existing file' do
          before do
            path.write 'ABC'
            path.mtime = Time.now - 3600
          end
          before { expect(path.mtime).to be < (Time.now - 30) }

          it 'should update modification time' do
            subject
            expect(path.mtime).to be_within(1).of(Time.now)
          end

          it 'should not change content' do
            subject
            expect(path.read).to eq 'ABC'
          end
        end

        context 'with existing directory' do
          before do
            path.mkdir
            path.mtime = Time.now - 3600
          end
          before { expect(path).to be_directory }
          before { expect(path.mtime).to be < (Time.now - 30) }

          it 'should should update modification time' do
            subject
            expect(path.mtime).to be_within(1).of(Time.now)
          end
        end

        context 'with file in non-existent directory' do
          let(:path) { Path '/dir/file' }

          it 'should raise ENOENT error' do
            expect { subject }.to raise_error(Errno::ENOENT, "No such file or directory - /dir/file")
          end
        end
      end

      # describe ".lookup" do
      #   before do
      #     Path.mock do |r|
      #       r.mkpath 'a/b/c/d'
      #       r.touch 'a/test.txt'
      #       r.touch 'a/b/c/config.yaml'
      #       r.touch 'a/config.yml'
      #     end
      #   end
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
    end
  end
end
