require_relative "async4r/version"
require "lightio"

LightIO::Monkey.patch_io!
LightIO::Monkey.patch_kernel!


module Async4r
  def self.included(klass)
    # klass.class_eval do
    #   require "lightio"

    #   LightIO::Monkey.patch_io!
    #   LightIO::Monkey.patch_kernel!
    # end

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
        @results = []
        collect_result = -> (val) { @results << val }
        blocks.map { |block| run_in_threadlet(collect_result, block) }.each(&:join)
        @results
      else
        run_in_threadlet(block).join
      end
    end

    private

    def run_in_threadlet(collect_result, block)
      LightIO::Beam.new do
        collect_result.call(block.call)
      end
    end
  end
end
