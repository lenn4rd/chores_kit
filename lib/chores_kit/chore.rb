require 'date'
require 'time'

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
      raise "Couldn't parse start time from attributes" if options[:at].nil?
      raise "Couldn't parse interval from attributes" unless options[:every].nil? || options[:every].is_a?(AS::Duration)

      at_ltz = Time.parse(options[:at]) || Time.now
      at_utc = Time.utc(*at_ltz) || Date.today.to_time.utc

      @metadata[:schedule] = {
        at:    at_utc,
        every: options[:every]
      }
    end

    def retry_failed(options)
      raise "Couldn't parse retry interval from attributes" unless options[:wait].nil? || options[:wait].is_a?(AS::Duration)

      wait = options[:wait] || 1.second
      retries = options[:retries] || 1

      @metadata[:retry_failed] = {
        wait: wait,
        retries: retries
      }
    end

    # Tasks and dependencies
    def task(options, &block)
      name, params = *options

      raise "Couldn't create task without a name" if name.nil?
      raise "Couldn't create task without a block" unless block_given?

      @dag.add_vertex(task: Task.new(name, params, &block))
    end

    def run(task, options)
      from = options[:triggered_by] || options[:upstream] || task
      to = options[:triggers] || options[:downstream] || task
    end

    # After-run callbacks
    def notify(*options, &block)
      raise "Couldn't create notifications without a block" unless block_given?

      conditions = *options
      conditions = DEFAULT_NOTIFICATIONS if options.empty?

      conditions.each do |condition|
        notification = Notification.new(condition)
        notification.instance_eval(&block)

        @notifications[condition] = notification
      end
    end
  end
end
