require 'date'
require 'as-duration'

module ChoresKit
  class Chore
    attr_reader :name, :tasks

    DEFAULT_NOTIFICATIONS = [:failed, :successful].freeze

    def initialize(name)
      @name = name
      @metadata = {}

      @dag = DAG.new
      @tasks = @dag.vertices

      @notifications = {}
    end

    # Metadata
    def description(string)
      @metadata[:description] = string
    end

    def schedule(options)
      @metadata[:schedule] = {
        at:    options.fetch(:at, Date.today.to_time),
        every: options.fetch(:every, 1.day)
      }
    end

    def retry_failed(options)
      @metadata[:retry_failed] = options
    end

    # Tasks and dependencies
    def task(options, &block)
      name, params = *options

      @dag.add_vertex(task: Task.new(name, params, &block))
    end

    def run(task, options)
      from = options[:triggered_by] || options[:upstream] || task
      to = options[:triggers] || options[:downstream] || task
    end

    # After-run callbacks
    def notify(conditions, &block)
      conditions.each do |condition|
        notification = Notification.new(condition)
        notification.instance_eval(&block)

        @notifications[condition] = notification
      end
    end
  end
end
