require "lightio"
require_relative "async4r/version"

LightIO::Monkey.patch_io!
LightIO::Monkey.patch_kernel!


module Async4r
  def self.included(klass)
    klass.include(ClassMethods)
    klass.extend(self)
  end

  def async(name)
    original_method = instance_method(name)

    remove_method(name)

    define_method(name) do |*args|
      -> { original_method.bind(self).call(*args) }
    end
  end

  module ClassMethods
    def await(blocks)
      if blocks.is_a? Array
        with_returning([], -> (acc, val) { acc << val }) do |collect_result|
          blocks.map { |block| run_in_threadlet(collect_result, block) }.each(&:join)
        end
      else
        with_returning(nil, ->(acc, val) { acc = val }) do |collect_result|
          run_in_threadlet(collect_result, block).join
        end
      end
    end

    private

    def with_returning(acc, collector)
      @accumulator = acc
      yield(-> (val) { collector.call(@accumulator, val) })
      @accumulator
    end


    def run_in_threadlet(collect_result, block)
      LightIO::Beam.new do
        collect_result.call(block.call)
      end
    end
  end
end
