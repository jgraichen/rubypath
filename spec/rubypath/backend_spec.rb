require 'spec_helper'

shared_examples "a path backend" do

  describe '#expand_path' do
    let(:base) { backend.cwd }
    subject { backend.expand_path path, base }

    context '~' do
      let(:path) { '~ '}

      it 'should expand to home directory of current user' do
        expect(subject).to eq backend.home_dir(backend.user)
      end
    end
  end
end
