require 'spec_helper'

describe Path do
  describe 'Construction' do
    let(:str)  { '/path/to/file' }
    let(:args) { [str] }
    let(:path) { described_class.new *args }
    subject { path }

    [:path, :to_path, :to_s].each do |mth|
      describe "##{mth}" do
        subject { path.send mth }

        it { should eq str }

        # Should not return same object as internal variable
        # to avoid in-place modifications like
        # `Path.new('/abc').path.delete!('abc')`
        it { should_not equal path.send(:instance_variable_get, :@path) }
      end
    end

    describe '#initialize' do
      context 'with multiple strings' do
        let(:args) { %w(path to a file.txt) }
        it { expect(subject.path).to eq 'path/to/a/file.txt' }
      end

      context 'with Pathname' do
        let(:args) { [Pathname.new('path/to/dir'), 'file.txt'] }
        it { expect(subject.path).to eq 'path/to/dir/file.txt' }
      end
    end

    describe 'class' do
      describe '#new' do
        subject { path }

        context 'with Path as argument' do
          let(:args) { [Path.new('/abc')] }
          it 'should return same object' do
            should equal args.first
          end
        end
      end

      describe '#like?' do
        subject { Path.like? obj }

        context 'positive list' do
          {
            'Path' => Path.new('/path/to/file.ext'),
            'Pathname' => Pathname.new('/path/to/file.ext'),
            'String' => '/path/to/file.ext',
            '#to_path' => Class.new{ def to_path; '/path/to/file.ext' end }.new,
            '#path' => Class.new{ def path; '/path/to/file.ext' end }.new
          }.each do |name, example|
            let(:obj) { example.dup }
            it("should accept #{name}") { should be true }
          end
        end
      end

      describe '#like_path' do
        subject { Path.like_path obj }

        context 'positive list' do
          {
            'Path' => Path.new('/path/to/file.ext'),
            'Pathname' => Pathname.new('/path/to/file.ext'),
            'String' => '/path/to/file.ext',
            '#to_path' => Class.new{ def to_path; '/path/to/file.ext' end }.new,
            '#path' => Class.new{ def path; '/path/to/file.ext' end }.new
          }.each do |name, example|
            let(:obj) { example.dup }
            it("should get path from #{name}") { should eq '/path/to/file.ext' }
          end
        end
      end

      describe '#to_proc' do
        it 'should allow to use Path as block' do
          expect(%w(path1 path2).map(&Path)).to eq [Path('path1'), Path('path2')]
        end
      end
    end
  end
end
