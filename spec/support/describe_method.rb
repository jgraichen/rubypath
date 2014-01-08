module DescribeMethod
  def describe_aliases(*args, &block)
    args.each do |mth|
      name = (mth == args.first ? "##{mth}" : "##{mth} (alias of #{args.first})")

      describe(name) do
        let(:mth) { mth }
      end.class_eval &block
    end
  end

  def describe_method(mth, opts = {}, &block)
    describe_aliases *([mth] + (opts[:aliases] || []).to_ary), &block
  end

  RSpec.configure{|c| c.extend DescribeMethod }
end
