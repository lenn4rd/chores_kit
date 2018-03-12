module Chores
  def self.define(name, &block)
    proxy = ChoresKit::DefinitionProxy.new(name)
    proxy.instance_eval(&block) if block_given?
    proxy.chore
  end
end
