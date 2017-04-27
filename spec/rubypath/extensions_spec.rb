# frozen_string_literal: true

require 'spec_helper'

describe Path do
  describe 'Extensions' do
    let(:path) { Path '/path/to/template.de.html.slim' }
    let(:dotfile) { Path '/path/to/.dotfile' }
    let(:dotfile_ext) { Path '/path/to/.dotfile.en.sh' }

    describe_method :extensions, aliases: [:exts] do
      subject { path.send described_method }

      it 'should return all file extensions' do
        should eq %w[de html slim]
      end

      context 'dotfile w/o ext' do
        let(:path) { dotfile }

        it 'should not return dotfile name as extension' do
          should eq []
        end
      end

      context 'dotfile with ext' do
        let(:path) { dotfile_ext }

        it 'should only return dotfile extension' do
          should eq %w[en sh]
        end
      end
    end

    describe '#extname' do
      subject { path.extname }

      it 'should return file extensions including dot' do
        should eq '.slim'
      end

      context 'dotfile w/o ext' do
        let(:path) { dotfile }

        it 'should not return dotfile name as extension' do
          should eq ''
        end
      end

      context 'dotfile with ext' do
        let(:path) { dotfile_ext }

        it 'should only return dotfile extension' do
          should eq '.sh'
        end
      end
    end

    describe '#pure_name' do
      subject { path.pure_name }

      it 'should return file name without extensions' do
        should eq 'template'
      end

      context 'dotfile w/o ext' do
        let(:path) { dotfile }

        it 'should return dotfile name' do
          should eq '.dotfile'
        end
      end

      context 'dotfile with ext' do
        let(:path) { dotfile_ext }

        it 'should return dotfile name w/o exts' do
          should eq '.dotfile'
        end
      end
    end

    describe_method :extension, aliases: [:ext] do
      subject { path.send described_method }

      it 'should return last file extensions' do
        should eq 'slim'
      end
    end

    describe_method :replace_extensions do
      let(:path) { Path "#{base}file#{exts}" }

      shared_examples 'extensions replacement' do
        context 'with array' do
          subject { path.send described_method, %w[en txt] }

          it 'should replace all file extensions' do
            should eq "#{base}file.en.txt"
          end

          it { should be_a Path }
        end

        context 'with multiple arguments' do
          subject { path.send described_method, 'en', 'txt' }

          it 'should replace all file extensions' do
            should eq "#{base}file.en.txt"
          end

          it { should be_a Path }
        end
      end

      shared_examples 'w/o ext' do
        let(:exts) { '' }
        it_behaves_like 'extensions replacement'

        context 'with replacement hash' do
          subject { path.send(described_method, 'txt' => 'html') }

          it 'should replace all file extensions' do
            should eq "#{base}file"
          end

          it { should be_a Path }
        end
      end

      shared_examples 'with single ext' do
        let(:exts) { '.txt' }
        it_behaves_like 'extensions replacement'

        context 'with replacement hash' do
          subject { path.send(described_method, 'txt' => 'html') }

          it 'should replace all file extensions' do
            should eq "#{base}file.html"
          end

          it { should be_a Path }
        end
      end

      shared_examples 'with multiple ext' do
        let(:exts) { '.en.html.slim' }
        it_behaves_like 'extensions replacement'

        context 'with replacement hash' do
          subject { path.send(described_method, 'en' => 'de') }

          it 'should replace all file extensions' do
            should eq "#{base}file.de.html.slim"
          end

          it { should be_a Path }
        end
      end

      context 'with path' do
        let(:base) { '/path/to/' }
        it_behaves_like 'w/o ext'
        it_behaves_like 'with single ext'
        it_behaves_like 'with multiple ext'
      end

      context 'with filename only' do
        let(:base) { '' }
        it_behaves_like 'w/o ext'
        it_behaves_like 'with single ext'
        it_behaves_like 'with multiple ext'
      end

      context 'with relative file path (I)' do
        let(:base) { './' }
        it_behaves_like 'w/o ext'
        it_behaves_like 'with single ext'
        it_behaves_like 'with multiple ext'
      end

      context 'with relative file path (II)' do
        let(:base) { 'path/' }
        it_behaves_like 'w/o ext'
        it_behaves_like 'with single ext'
        it_behaves_like 'with multiple ext'
      end
    end

    describe_method :replace_extension do
      let(:path) { Path "#{base}#{file}#{ext}" }

      shared_examples 'extension replacement' do
        context 'with array' do
          subject { path.send described_method, %w[mobile txt] }

          it 'should replace last file extensions' do
            should eq "#{base}#{file}.mobile.txt"
          end

          it { should be_a Path }
        end

        context 'with multiple arguments' do
          subject { path.send described_method, 'mobile', 'txt' }

          it 'should replace last file extensions' do
            should eq "#{base}#{file}.mobile.txt"
          end

          it { should be_a Path }
        end

        context 'with single string' do
          subject { path.send described_method, 'haml' }

          it 'should replace last file extensions' do
            should eq "#{base}#{file}.haml"
          end

          it { should be_a Path }
        end
      end

      shared_examples 'w/o ext' do
        let(:file) { 'file' }
        let(:ext)  { '' }
        it_behaves_like 'extension replacement'
      end

      shared_examples 'with single ext' do
        let(:file) { 'file' }
        let(:ext)  { '.txt' }
        it_behaves_like 'extension replacement'
      end

      shared_examples 'with multiple ext' do
        let(:file) { 'file.de' }
        let(:ext)  { '.txt' }
        it_behaves_like 'extension replacement'
      end

      context 'on path file' do
        let(:base) { '/path/to/file/' }
        it_behaves_like 'w/o ext'
        it_behaves_like 'with single ext'
        it_behaves_like 'with multiple ext'
      end

      context 'on relative path file' do
        let(:base) { 'to/file/' }
        it_behaves_like 'w/o ext'
        it_behaves_like 'with single ext'
        it_behaves_like 'with multiple ext'
      end

      context 'on relative root path file' do
        let(:base) { './' }
        it_behaves_like 'w/o ext'
        it_behaves_like 'with single ext'
        it_behaves_like 'with multiple ext'
      end

      context 'on filename only' do
        let(:base) { '' }
        it_behaves_like 'w/o ext'
        it_behaves_like 'with single ext'
        it_behaves_like 'with multiple ext'
      end
    end
  end
end
