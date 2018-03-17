class Notification
  def initialize(condition)
    @condition = condition
    @commands = []
  end

  # rubocop:disable Style/MethodMissing
  def method_missing(name, *args)
  end
  # rubocop:enable Style/MethodMissing
end
