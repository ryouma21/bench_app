class MenuGenerator
  def initialize(latest_one_rm, trend)
    @latest_one_rm = latest_one_rm
    @trend = trend
  end

  def menu
    case @trend
    when :up
      up_menu
    when :down
      down_menu
    else
      flat_menu
    end
  end

  private

  def up_menu
    {
      percentage: 0.85,
      reps: 3,
      sets: 3,
      weight: rounded_weight(@latest_one_rm * 0.85)
    }
  end

  def flat_menu
    {
      percentage: 0.75,
      reps: 5,
      sets: 3,
      weight: rounded_weight(@latest_one_rm * 0.75)
    }
  end

  def down_menu
    {
      percentage: 0.65,
      reps: 5,
      sets: 3,
      weight: rounded_weight(@latest_one_rm * 0.65)
    }
  end

  def rounded_weight(value)
    (value / 2.5).round * 2.5
  end
end
