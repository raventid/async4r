module Async4r
  module Async
    module Methods
      def self.included(klass)
        klass.include(ClassMethods)
        klass.extend(self)
      end

      def async(name)
        original_method = instance_method(name)

        remove_method(name)

        define_method(name) do |*args|
          lambda do
            original_method.bind(self).call(*args)
          end
        end
      end

      module ClassMethods
        def await(blocks)
          if blocks.is_a? Array
            blocks.each { |block| run_in_threadlet(block) }.each(&:join)
          else
            run_in_threadlet(block).join
          end
        end

        private

        def run_in_threadlet(block)
          LightIO::Beam.new do
            block.call
          end
        end
      end
    end
  end
end
