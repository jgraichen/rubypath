# frozen_string_literal: true

require 'spec_helper'

describe Path do
  describe 'File Predicates' do
    with_backends :mock, :sys do
      describe_method :file? do
        let(:path) { Path '/file.txt' }
        before { expect(path).to_not be_existent }
        subject { path.send(described_method) }

        context 'with existing file' do
          before { path.touch }
          it { should eq true }
        end

        context 'with existing but wrong node (dir)' do
          before { path.mkdir }
          it { should eq false }
        end

        context 'with not existent file' do
          it { should eq false }
        end
      end

      describe_method :directory? do
        let(:dir) { Path '/dir' }
        before { expect(dir).to_not be_existent }
        subject { dir.send(described_method) }

        context 'with existing directory' do
          before { dir.mkdir }
          it { should eq true }
        end

        context 'with existing but wrong node (file)' do
          before { dir.touch }
          it { should eq false }
        end

        context 'with not existent directory' do
          it { should eq false }
        end
      end

      describe_method :exists?, aliases: %i[exist? existent?] do
        let(:path) { Path '/file' }
        subject { path.send described_method }

        context 'with existing directory' do
          before { path.mkdir }
          it { should eq true }
        end

        context 'with existing file' do
          before { path.touch }
          it { should eq true }
        end

        context 'with non-existing node' do
          it { should eq false }
        end
      end
    end
  end
end
