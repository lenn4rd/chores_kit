module ChoresKit
  class DefinitionProxy
    attr_reader :chore

    def initialize(name)
      @chore = Chore.new(name)
    end

    # rubocop:disable Style/MethodMissing
    def method_missing(name, *args, &block)
      args = {} if args.empty?

      if block_given?
        @chore.send(name, args, &block)
      else
        @chore.send(name, *args)
      end
    end
    # rubocop:enable Style/MethodMissing
  end
end
