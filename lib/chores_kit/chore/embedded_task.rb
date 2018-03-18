module ChoresKit
  module EmbeddedTask
    def name
      task.name
    end

    def run
      puts "Running task #{name}"
      task.run

      return unless successors

      Thread.abort_on_exception = true
      threads = []

      threads << Thread.new do
        successors.map(&:run)
      end

      threads.map(&:join)
    end

    private

    def task
      self[:task]
    end
  end
end
