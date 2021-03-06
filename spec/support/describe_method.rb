# frozen_string_literal: true

module DescribeMethod
  def describe_aliases(*args, &block)
    args.each do |mth|
      name = mth == args.first ? "##{mth}" : "##{mth} (alias of #{args.first})"

      describe(name) do
        let(:described_method) { mth }
        module_eval(&block)
      end
    end
  end

  def describe_method(mth, opts = {}, &block)
    describe_aliases(*([mth] + (opts[:aliases] || []).to_ary), &block)
  end

  RSpec.configure {|c| c.extend DescribeMethod }
end
