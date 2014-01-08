require 'spec_helper'

describe Path do
  describe 'Identity' do
    let(:str)  { '/path/to/file' }
    let(:args) { [str] }
    let(:path) { described_class.new *args }
    subject { path }

    describe_aliases :path, :to_path, :to_s do
      subject { path.send mth }

      it { should eq str }

      # Should not return same object as internal variable
      # to avoid in-place modifications like
      # `Path.new('/abc').path.delete!('abc')`
      it { should_not equal path.send(:instance_variable_get, :@path) }
    end
  end
end
