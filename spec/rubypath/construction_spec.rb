# frozen_string_literal: true
require 'spec_helper'

describe Path do
  describe 'Construction' do
    let(:str)  { '/path/to/file' }
    let(:args) { [str] }
    let(:path) { described_class.new(*args) }
    subject { path }

    describe_method :path, aliases: [:to_path, :to_s] do
      subject { path.send described_method }

      it { should eq str }

      # Should not return same object as internal variable
      # to avoid in-place modifications like
      # `Path.new('/abc').path.delete!('abc')`
      it { should_not equal path.send(:instance_variable_get, :@path) }
    end

    describe '#initialize' do
      context 'w/o args' do
        let(:args) { %w() }
        it { expect(subject.path).to eq '' }
        it { should be_a Path }
      end

      context 'with multiple strings' do
        let(:args) { %w(path to a file.txt) }
        it { expect(subject.path).to eq 'path/to/a/file.txt' }
        it { should be_a Path }
      end

      context 'with Pathname' do
        let(:args) { [Pathname.new('path/to/dir'), 'file.txt'] }
        it { expect(subject.path).to eq 'path/to/dir/file.txt' }
        it { should be_a Path }
      end

      context 'with Numerals' do
        let(:args) { ['path', 5, 'to', 4.5, 'file.txt'] }
        it { expect(subject.path).to eq 'path/5/to/4.5/file.txt' }
        it { should be_a Path }
      end
    end

    describe 'class' do
      describe '#new' do
        context 'with Path as argument' do
          let(:args) { [Path.new('/abc')] }
          it('should return same object') { should equal args.first }
        end

        context 'w/o args' do
          let(:args) { [] }
          it('should return Path::EMPTY') { should equal Path::EMPTY }
        end
      end

      describe '#like?' do
        subject { Path.like? obj }

        context 'positive list' do
          {
            'Path' => Path.new('/path/to/file.ext'),
            'Pathname' => Pathname.new('/path/to/file.ext'),
            'String' => '/path/to/file.ext',
            '#to_path' => Class.new do
                            def to_path
                              '/path/to/file.ext'
                            end
                          end.new,
            '#path' => Class.new do
                         def path
                           '/path/to/file.ext'
                         end
                       end.new
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
            '#to_path' => Class.new do
                            def to_path;
                              '/path/to/file.ext'
                            end
                          end.new,
            '#path' => Class.new do
                         def path;
                           '/path/to/file.ext'
                         end
                       end.new
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
