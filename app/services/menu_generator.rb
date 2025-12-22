class MenuGenerator
  FLAT_PERCENT = 0.75  # 維持・定着用
  DOWN_PERCENT = 0.65  # 回復・調整用
  PLATE        = 2.5

  # ボタン用の微調整（5%だけ上下）
  LIGHTER_DELTA = -0.05
  HEAVIER_DELTA =  0.05
  MIN_PERCENT   =  0.55
  MAX_PERCENT   =  0.90

  def initialize(latest_one_rm:, reference_one_rm:, trend:)
    @latest_one_rm = latest_one_rm
    @reference_one_rm = reference_one_rm
    @trend = trend
  end

  # intensity: :normal / :lighter / :heavier
  def menu(intensity = :normal)
    base = base_menu # まず通常のメニュー（flat or down）を作る

    percent = adjust_percent(base[:percentage], intensity)

    base.merge(
      percentage: percent,
      weight: rounded_weight(base_weight_base_one_rm(base[:type]) * percent)
    )
  end

  private

  # 「どの基準1RMを使うか」も含めて返す
  def base_menu
    case @trend
    when :down
      { type: :down, percentage: DOWN_PERCENT, reps: 5, sets: 3 }
    else
      { type: :flat, percentage: FLAT_PERCENT, reps: 5, sets: 3 }
    end
  end

  # downは latest基準、flatは reference基準（あなたの方針を維持）
  def base_weight_base_one_rm(type)
    type == :down ? @latest_one_rm : @reference_one_rm
  end

  def adjust_percent(p, intensity)
    case intensity
    when :lighter
      [[p + LIGHTER_DELTA, MIN_PERCENT].max, MAX_PERCENT].min
    when :heavier
      [[p + HEAVIER_DELTA, MIN_PERCENT].max, MAX_PERCENT].min
    else
      p
    end
  end

  def rounded_weight(value)
    (value / PLATE).round * PLATE
  end
end

