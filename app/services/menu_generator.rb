class MenuGenerator
  FLAT_PERCENT = 0.75  # 維持・定着用
  DOWN_PERCENT = 0.65  # 回復・調整用
  PLATE        = 2.5
  def initialize(latest_one_rm:, reference_one_rm:, trend:)
    @latest_one_rm = latest_one_rm
    @reference_one_rm = reference_one_rm
    @trend = trend
  end

  def menu
    case @trend
    when :down
      down_menu
    else
      flat_menu
    end
  end

  private

  # Phase1以降用：刺激を入れる日
  # def up_menu
  #   {
  #     percentage: 0.85,
  #     reps: 3,
  #     sets: 3,
  #     weight: rounded_weight(@reference_one_rm * 0.85)
  #   }
  # end
 
   # フラット時：直近平均1RMを基準に安定した負荷を出す
  def flat_menu
    {
      percentage: FLAT_PERCENT,
      reps: 5,
      sets: 3,
      weight: rounded_weight(@reference_one_rm * FLAT_PERCENT)
    }
  end
  # down時：当日の状態（latest）を基準に無理しない
  def down_menu
    {
      percentage: DOWN_PERCENT,
      reps: 5,
      sets: 3,
      weight: rounded_weight(@latest_one_rm * DOWN_PERCENT)
    }
  end

  def rounded_weight(value)
    (value / PLATE).round * PLATE
  end
end
