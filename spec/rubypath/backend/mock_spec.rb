require 'spec_helper'

describe Path::Backend::Mock do
  let(:backend) { described_class.new }

  context '#expand_path' do
    it_should_behave_like 'Backend#expand_path'
  end
end
