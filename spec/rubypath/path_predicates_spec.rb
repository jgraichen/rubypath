# frozen_string_literal: true
require 'spec_helper'

describe Path do
  describe 'Path Predicates' do
    describe '#absolute?' do
      subject { Path(path).absolute? }

      context 'with absolute path' do
        let(:path) { '/abs/path/to/file' }
        it { should be true }
      end

      context 'with relative path' do
        let(:path) { 'path/to/file' }
        it { should be false }
      end
    end

    describe '#relative?' do
      subject { Path(path).relative? }

      context 'with absolute path' do
        let(:path) { '/abs/path/to/file' }
        it { should be false }
      end

      context 'with relative path' do
        let(:path) { 'path/to/file' }
        it { should be true }
      end
    end

    describe '#mountpoint?' do
      let(:path) { Path('/tmp') }

      context 'without args' do
        it 'should invoke backend with current path' do
          expect(Path::Backend.instance).to receive(:mountpoint?).with('/tmp').and_return(false)
          path.mountpoint?
        end
      end

      context 'with args' do
        it 'should invoke backend with joined path' do
          expect(Path::Backend.instance).to receive(:mountpoint?).with('/tmp/fuu').and_return(false)
          path.mountpoint?('fuu')
        end
      end
    end

    describe_method :dotfile? do
      subject { path.dotfile? }

      context 'with dotfile' do
        let(:path) { Path '.abc' }
        it { should be true }
      end

      context 'with path to dotfile' do
        let(:path) { Path '/apth/to/.abc' }
        it { should be true }
      end

      context 'with normal file' do
        let(:path) { Path '/path/to/file' }
        it { should be false }
      end

      context 'with path to file within a dotdir' do
        let(:path) { Path '/home/user/.local/file' }
        it { should be false }
      end
    end
  end
end
