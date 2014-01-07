
shared_examples "Backend#expand_path" do
  let(:base) { backend.getwd }
  subject { backend.expand_path path, base }

  context '~' do
    let(:path) { '~' }

    it 'should expand to home directory of current user' do
      expect(subject).to eq backend.home(backend.user)
    end
  end

  context '~root' do
    let(:path) { "~root" }

    it 'should expand to home directory of given user' do
      expect(subject).to eq '/root'
    end
  end

  context '~/tmp' do
    let(:path) { "~/tmp" }

    it 'should expand to tmp directory of current user' do
      expect(subject).to eq ::File.join(backend.home(backend.user), 'tmp')
    end
  end

  context '~root/tmp' do
    let(:path) { "~root/tmp" }

    it 'should expand to tmp directory of given user' do
      expect(subject).to eq '/root/tmp'
    end
  end
end
