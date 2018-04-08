require 'benchmark'

module ChoresKit
  class Task
    attr_reader :name

    def initialize(name, *args)
      @name = name
      @args = args
    end

    def run
      raise "Task doesn't have any executors" if @callable.nil?

      puts "Running #{@callable.friendly_name} executor with command #{@callable.command} at #{Time.now}"

      duration = Benchmark.realtime do
        @callable.run!
      end

      puts "Took #{Integer(duration * 1000)}ms to run\n\n"
    end

    # rubocop:disable Style/MethodMissing
    def method_missing(name, *args)
      attributes = { callable: args, callee: self }

      if name == :sh
        @callable = Executors::Shell.new(name, attributes)
      end
    end
    # rubocop:enable Style/MethodMissing
  end
end
