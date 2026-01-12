# app/services/trend_analyzer_phase0.rb
class TrendAnalyzerPhase0

  DAYS = 14
  DOWN_THRESHOLD = 0.95 # 基準値の95%未満なら「調整（down）」

  def initialize(records)
    @records = records
  end

  def trend
    return :flat if @records.blank?
    # 直近の平均1RMを基準値として使う（ブレで「下がり続ける」問題を抑える）
    reference = reference_recent_average
    latest    = latest_one_rm # 最新の1RM

    return :flat if reference.nil? || latest.nil?
      #基準値より5%以上落ちている場合は調整（down）
    if latest < reference *  DOWN_THRESHOLD
      :down
    else
      :flat
    end
  end

    # UX用メッセージ
  def message
    case trend
    when :flat
      "基礎は安定しています。この調子で続けましょう。"
    when :down
      "少し疲れが見えます。今日は回復寄りでいきましょう。"
    end
  end

  # 直近14日間の平均1RM（基準値）
  def reference_recent_average
    rms = @records
            .recent_days(DAYS)
            .map(&:estimated_one_rm)


    return nil if rms.empty?
    rms.sum / rms.size
  end

  private
 # 将来用：直近14日で一番高かった1RM（最大値）
  def reference_one_rm
    @records
      .recent_days(DAYS)
      .map(&:estimated_one_rm)
      .max
  end

  def latest_one_rm
    @records.last&.estimated_one_rm
  end
end
