module WithBackend

  def with_backends(*args, &block)
    args.each do |backend|
      be = case backend
      when :mock
        lambda { |ex| Path::Backend.mock &ex }
      when :sys
        lambda { |ex| Path::Backend.mock(root: :tmp, &ex) }
      else
        raise ArgumentError.new 'Unknown backend.'
      end

      ctx = describe "with #{backend.upcase} FS" do
        around do |example|
          be.call(example)
        end
      end
      ctx.class_eval &block
    end
  end

  RSpec.configure{|c| c.extend WithBackend }
end
