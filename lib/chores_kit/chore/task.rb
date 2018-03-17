module ChoresKit
  class Task
    attr_reader :name

    def initialize(name, args, &block)
      @name = name
      @args = args
      @command = block
    end

    # rubocop:disable Style/MethodMissing
    def method_missing(name, *args)
    end
    # rubocop:enable Style/MethodMissing
  end
end
