class Chores
  attr_reader :chore

  def self.define(name, &block)
    proxy = ChoresKit::DefinitionProxy.new(name)
    proxy.instance_eval(&block) if block_given?
    proxy.chore
  end

  def initialize(filename)
    @chore = instance_eval(File.read(filename))
  end

  def self.load(filename)
    new(filename).chore
  end

  def self.load_all
    tasks = Pathname.glob('tasks/**/*.rb')

    tasks.each do |task_file|
      load(Pathname.pwd + task_file)
    end
  end

  def run
    @chore.run!
  end
end
