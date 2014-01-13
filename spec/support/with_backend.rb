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

      describe "with #{backend.upcase} FS" do
        let(:backend_type) { backend }
        around do |example|
          be.call(example)
        end

        module_eval &block
      end
    end
  end

  def pending_backend(*args)
    before { pending "Pending on #{backend_type} backend." if args.include? backend_type }
  end

  RSpec.configure{|c| c.extend WithBackend }
end
