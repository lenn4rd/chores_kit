require 'date'
require 'time'

require 'as-duration'

module ChoresKit
  class Chore
    attr_reader :name

    DEFAULT_NOTIFICATIONS = %i[successful failed].freeze

    def initialize(name)
      @name = name
      @metadata = {}

      @dag = DAG.new(mixin: EmbeddedTask)
      @tasks = @dag.vertices

      @notifications = {}
    end

    # Metadata
    def description(string)
      @metadata[:description] = string
    end

    # rubocop:disable Metrics/AbcSize
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
    # rubocop:enable Metrics/AbcSize

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

      task = Task.new(name, params)
      task.instance_eval(&block)

      @dag.add_vertex(name: name, task: task)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def run(task, options = {})
      from = options[:triggered_by] || options[:upstream] || task
      to = options[:triggers] || options[:downstream] || task

      tasks = @tasks.map(&:name)
      direction = options[:upstream] || options[:triggered_by] ? 'upstream' : 'downstream'

      # Throw an error if either up- or downstream task doesn't exist
      non_existing_tasks = ([from, to] - tasks).uniq
      raise "Couldn't set #{direction} dependency for non-existing task #{non_existing_tasks.first}" if non_existing_tasks.any?

      # Throw an error if unsupported dependencies are set
      raise "Multiple upstream tasks aren't supported" if from.is_a?(Array)
      raise "Multiple downstream tasks aren't supported" if to.is_a?(Array)

      # Set explicit root task and skip further processing if the Chore has
      # just one task defined or if only one of its tasks is set to run
      if tasks.one? || from == to
        @dag.root!(@dag.find_by(name: from))
        return
      end

      v1 = @dag.vertices.detect { |vertex| vertex[:name] == from }
      v2 = @dag.vertices.detect { |vertex| vertex[:name] == to }

      @dag.add_edge(from: v1, to: v2)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

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

    def run!
      @dag.root.run
    end
  end
end
