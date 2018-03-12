module ChoresKit
  class Task
    attr_reader :name

    def initialize(name, args, &block)
      @name = name
      @args = args
      @command = block
    end

    def method_missing(name, *args)
    end
  end
end
