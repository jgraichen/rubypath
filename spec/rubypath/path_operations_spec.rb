# frozen_string_literal: true

require 'spec_helper'

describe Path do
  describe 'Path Operations' do
    let(:str)  { '/root/path' }
    let(:args) { [str] }
    let(:path) { Path(*args) }
    subject { path }

    describe_method :join do
      subject { path.send(described_method, *join_args) }

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

    describe_method :cleanpath do
      subject { path.send(described_method) }

      context 'with out dot components' do
        let(:path) { Path 'path/to/file.txt' }
        it { should eq 'path/to/file.txt' }
      end

      context 'with leading dot' do
        let(:path) { Path './file.txt' }
        it { should eq 'file.txt' }
      end

      context 'with including dot' do
        let(:path) { Path 'path/to/./file.txt' }
        it { should eq 'path/to/file.txt' }
      end

      context 'with double dot' do
        let(:path) { Path 'path/to/../file.txt' }
        it { should eq 'path/file.txt' }
      end

      context 'with multiple dots' do
        let(:path) { Path 'path/to/../../opath/to/./../file.txt' }
        it { should eq 'opath/file.txt' }
      end

      context 'with trailing slash' do
        let(:path) { Path 'path/to/../../dir/' }
        it { expect(subject.to_s).to eq 'dir/' }
      end
    end

    describe_method :each_component do
      let(:block) { nil }
      let(:opts) { {} }
      let(:str) { '/path/to/templates/dir/' }
      subject { path.send described_method, opts, &block }

      it { should be_a Enumerator }

      it 'should return all components' do
        expect(subject.to_a).to eq %w[path to templates dir]
      end

      context 'with empty option' do
        let(:opts) { {empty: true} }

        it 'should also return empty path components' do
          expect(subject.to_a).to eq([''] + %w[path to templates dir] + [''])
        end
      end

      context 'with block' do
        let(:block) { proc {|fn| fn } }

        it 'should yield components' do
          expect do |b|
            path.send described_method, &b
          end.to yield_successive_args('path', 'to', 'templates', 'dir')
        end

        it { should eq path }
      end
    end

    describe_method :components do
      let(:str) { '/path/to/templates/index.html' }
      subject { path.send described_method }

      it { should be_a Array }
      it { should eq %w[path to templates index.html] }

      context 'with should include leading empty components' do
        let(:str) { 'path/to/dir/' }
        subject { path.send described_method, empty: true }

        it { should eq ['path', 'to', 'dir', ''] }
      end
    end

    describe_method :dirname, aliases: [:parent] do
      shared_examples 'dirname' do
        it 'should return parent directory' do
          expect(Path(base, 'path/to/file').send(described_method))
            .to eq "#{base}path/to"
        end

        context 'when hitting root' do
          it 'should return root' do
            expect(Path(base, 'path').send(described_method)).to eq base[0]
          end
        end

        context 'when being root' do
          it 'should return nil' do
            expect(Path(base[0]).send(described_method)).to eq nil
          end
        end
      end

      context 'with absolute path' do
        let(:base) { '/' }
        it_behaves_like 'dirname'
      end

      context 'with relative path' do
        let(:base) { './' }
        it_behaves_like 'dirname'
      end
    end

    with_backends :mock, :sys do
      describe_method :expand, aliases: %i[expand_path
                                           absolute absolute_path] do
        let(:cwd) { '/working/dir' }
        let(:base) { cwd }
        let(:args) { [] }
        before do
          Path.mock do |_root, back|
            back.cwd = cwd
            back.current_user = 'test'
            back.homes = {'test' => '/home/test', 'otto' => '/srv/home/otto'}
          end
        end

        around {|example| Path::Backend.mock(&example) }

        shared_examples '#expand' do
          subject { Path(path).send(described_method, *args) }

          it 'should expand path' do
            expect(subject).to eq expanded_path
          end

          it { should be_a Path }
        end

        context '~' do
          let(:path) { '~' }
          let(:expanded_path) { '/home/test' }
          it_behaves_like '#expand'
        end

        context '~/path' do
          let(:path) { '~/path/to/file.txt' }
          let(:expanded_path) { '/home/test/path/to/file.txt' }
          it_behaves_like '#expand'
        end

        context '~user' do
          let(:path) { '~otto' }
          let(:expanded_path) { '/srv/home/otto' }
          it_behaves_like '#expand'
        end

        context '~user/path' do
          let(:path) { '~otto/path/to/file.txt' }
          let(:expanded_path) { '/srv/home/otto/path/to/file.txt' }
          it_behaves_like '#expand'
        end

        context '/abs/path' do
          let(:path) { '/abs/path/to/file.txt' }
          let(:expanded_path) { '/abs/path/to/file.txt' }
          it_behaves_like '#expand'
        end

        context 'rel/path' do
          let(:path) { 'rel/path/to/file.txt' }
          let(:expanded_path) { '/working/dir/rel/path/to/file.txt' }
          it_behaves_like '#expand'
        end

        context './path' do
          let(:path) { './path/to/file.txt' }
          let(:expanded_path) { '/working/dir/path/to/file.txt' }
          it_behaves_like '#expand'
        end

        context 'with base option' do
          let(:base) { '/base/./' }
          let(:args) { [base: '/base/./'] }

          context '~' do
            let(:path) { '~' }
            let(:expanded_path) { '/home/test' }
            it_behaves_like '#expand'
          end

          context '~/path' do
            let(:path) { '~/path/to/file.txt' }
            let(:expanded_path) { '/home/test/path/to/file.txt' }
            it_behaves_like '#expand'
          end

          context '~user' do
            let(:path) { '~otto' }
            let(:expanded_path) { '/srv/home/otto' }
            it_behaves_like '#expand'
          end

          context '~user/path' do
            let(:path) { '~otto/path/to/file.txt' }
            let(:expanded_path) { '/srv/home/otto/path/to/file.txt' }
            it_behaves_like '#expand'
          end

          context '/abs/path' do
            let(:path) { '/abs/path/to/file.txt' }
            let(:expanded_path) { '/abs/path/to/file.txt' }
            it_behaves_like '#expand'
          end

          context 'rel/path' do
            let(:path) { 'rel/path/to/file.txt' }
            let(:expanded_path) { '/base/rel/path/to/file.txt' }
            it_behaves_like '#expand'
          end

          context './path' do
            let(:path) { './path/to/file.txt' }
            let(:expanded_path) { '/base/path/to/file.txt' }
            it_behaves_like '#expand'
          end
        end

        context 'with path args' do
          let(:args) { ['..', 'fuu', 'net.txt'] }

          context '~' do
            let(:path) { '~' }
            let(:expanded_path) { '/home/fuu/net.txt' }
            it_behaves_like '#expand'
          end

          context '~/path' do
            let(:path) { '~/path/to/file.txt' }
            let(:expanded_path) { '/home/test/path/to/fuu/net.txt' }
            it_behaves_like '#expand'
          end

          context '~user' do
            let(:path) { '~otto' }
            let(:expanded_path) { '/srv/home/fuu/net.txt' }
            it_behaves_like '#expand'
          end

          context '~user/path' do
            let(:path) { '~otto/path/to/file.txt' }
            let(:expanded_path) { '/srv/home/otto/path/to/fuu/net.txt' }
            it_behaves_like '#expand'
          end

          context '/abs/path' do
            let(:path) { '/abs/path/to/file.txt' }
            let(:expanded_path) { '/abs/path/to/fuu/net.txt' }
            it_behaves_like '#expand'
          end

          context 'rel/path' do
            let(:path) { 'rel/path/to/file.txt' }
            let(:expanded_path) { '/working/dir/rel/path/to/fuu/net.txt' }
            it_behaves_like '#expand'
          end

          context './path' do
            let(:path) { './path/to/file.txt' }
            let(:expanded_path) { '/working/dir/path/to/fuu/net.txt' }
            it_behaves_like '#expand'
          end
        end
      end
    end

    describe_method :relative_from, aliases: [:relative_path_from] do
      let(:base) { Path '/path/three/four/five' }
      let(:path) { Path '/path/one/two' }
      subject { path.relative_from base }

      it { should eq '../../../one/two' }

      context 'with collapsing paths' do
        let(:base) { Path '/path/one/two' }
        let(:path) { Path '/path/one' }
        it { should eq '..' }
      end

      context 'with relative paths' do
        let(:base) { Path 'path/one' }
        let(:path) { Path 'path/two' }
        it { should eq '../two' }
      end

      context 'with mixed paths' do
        let(:base) { Path '/root/path/one' }
        let(:path) { Path 'path/two' }
        subject { -> { path.relative_from base } }
        it { should raise_error ArgumentError }
      end

      context 'with dots in path' do
        let(:base) { Path '/path/one/three/../two' }
        let(:path) { Path '/path/one/two/six' }
        it { should eq 'six' }
      end

      context 'with same path (I)' do
        let(:base) { Path '/path/one/two/six' }
        let(:path) { Path '/path/one/two/six' }
        it { should eq '.' }
        it { expect(subject.to_s).to eq '.' }
      end

      context 'with same path (I)' do
        let(:base) { Path '/' }
        let(:path) { Path '/' }
        it { should eq '.' }
        it { expect(subject.to_s).to eq '.' }
      end

      describe 'preserve trailing slash' do
        let(:base) { Path('/blog/2014/06/my-blog-title-1/').dirname }
        let(:path) { Path '/blog/2014/07/another-blog-title/' }
        it { expect(subject.to_s).to eq '../07/another-blog-title/' }
      end
    end

    describe_method :ascend, aliases: [:each_ancestors] do
      shared_examples 'ascend' do
        context 'with block' do
          let(:block) { proc {} }
          subject { path.send described_method, &block }

          it { should eq path }

          it 'should yield part paths' do
            expect {|b| path.send(described_method, &b) }
              .to yield_successive_args(*expected_paths)
          end

          it 'should yield Path objects' do
            expect {|b| path.send(described_method, &b) }
              .to yield_successive_args(*expected_paths.map { Path })
          end
        end

        context 'w/o block' do
          subject { path.send described_method }

          it { should be_a Enumerator }

          it 'should yield part paths' do
            expect {|b| subject.each(&b) }
              .to yield_successive_args(*expected_paths)
          end

          it 'should yield path objects' do
            expect {|b| subject.each(&b) }
              .to yield_successive_args(*expected_paths.map { Path })
          end
        end
      end

      context 'with absolute path' do
        let(:path) { Path '/path/to/file.txt' }
        let(:expected_paths) { %w[/path/to/file.txt /path/to /path /] }
        it_behaves_like 'ascend'
      end

      context 'with relative path' do
        let(:path) { Path 'path/to/file.txt' }
        let(:expected_paths) { %w[path/to/file.txt path/to path .] }
        it_behaves_like 'ascend'
      end
    end

    describe '#as_relative' do
      subject { Path(path).as_relative }

      context 'with absolute path' do
        let(:path) { '/path/to/file.txt' }
        it { should eq 'path/to/file.txt' }
      end

      context 'with relative path' do
        let(:path) { 'path/to/file.txt' }
        it { should eq 'path/to/file.txt' }
      end

      context 'with filename only' do
        let(:path) { 'file.txt' }
        it { should eq 'file.txt' }
      end
    end

    describe '#as_absolute' do
      subject { Path(path).as_absolute }

      context 'with absolute path' do
        let(:path) { '/path/to/file.txt' }
        it { should eq '/path/to/file.txt' }
      end

      context 'with relative path' do
        let(:path) { 'path/to/file.txt' }
        it { should eq '/path/to/file.txt' }
      end

      context 'with filename only' do
        let(:path) { 'file.txt' }
        it { should eq '/file.txt' }
      end
    end

    describe_method :ancestors do
      shared_examples 'ancestors' do
        subject { path.send described_method }

        it { should be_a Array }

        it 'should contain part paths' do
          expect {|b| subject.each(&b) }.to \
            yield_successive_args(*expected_paths)
        end

        it 'should contain path objects' do
          expect {|b| subject.each(&b) }.to \
            yield_successive_args(*expected_paths.map { Path })
        end
      end

      context 'with absolute path' do
        let(:path) { Path '/path/to/file.txt' }
        let(:expected_paths) { %w[/path/to/file.txt /path/to /path /] }
        it_behaves_like 'ancestors'
      end

      context 'with relative path' do
        let(:path) { Path 'path/to/file.txt' }
        let(:expected_paths) { %w[path/to/file.txt path/to path .] }
        it_behaves_like 'ancestors'
      end
    end
  end
end
