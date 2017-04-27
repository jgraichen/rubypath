# frozen_string_literal: true

#
module WithBackend
  def with_backends(*args, &block) # rubocop:disable AbcSize, MethodLength
    args.each do |backend|
      be = case backend
             when :mock
               ->(ex) { Path::Backend.mock(&ex) }
             when :sys
               ->(ex) { Path::Backend.mock(root: :tmp, &ex) }
             else
               raise ArgumentError.new 'Unknown backend.'
           end

      next if ENV["FS_#{backend.upcase}"] == '0'

      describe "with #{backend.upcase} FS" do
        let(:backend_type) { backend }
        around do |example|
          be.call(example)
        end

        module_eval(&block)
      end
    end
  end
  alias with_backend with_backends

  def pending_backend(*args)
    before do
      if args.include? backend_type
        pending "Pending on #{backend_type} backend."
      end
    end
  end

  RSpec.configure {|c| c.extend WithBackend }
end
