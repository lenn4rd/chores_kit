require 'open3'

module ChoresKit
  module Executors
    class Shell
      attr_reader :name

      def initialize(name, attributes)
        @name = name
        @callee = attributes.fetch(:callee)
        @callable = attributes.fetch(:callable)
      end

      def friendly_name
        'Shell'
      end

      def command
        @callable.join(' ')
      end

      def run!
        output, status = Open3.capture2e(*@callable)

        raise "Running #{friendly_name} '#{@callable}' failed with status #{status.exitstatus}. Error message: #{output}" unless status.success?
      end
    end
  end
end
