require 'spec_helper'

describe Path do
  describe 'File Operations' do
    let(:path) { Path('/path/to/file.txt') }

    [:name, :basename].each do |mth|
      describe "##{mth}" do
        subject { path.send mth }

        it 'should return file name' do
          should eq 'file.txt'
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
