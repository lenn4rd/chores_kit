class Notification
  def initialize(condition)
    @condition = condition
    @commands = []
  end

  def method_missing(name, *args)
  end
end
