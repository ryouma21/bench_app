# app/services/trend_analyzer_phase0.rb
class TrendAnalyzerPhase0
  def initialize(records)
    @records = records
  end

  def trend
    return :flat if @records.blank?

    reference = reference_one_rm # 直近14日で一番高かった1RM
    latest    = latest_one_rm # 最新の1RM

    return :flat if reference.nil? || latest.nil?
      # -5% 以内は維持
    if latest < reference * 0.95
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

  # Phase0.5用：直近平均1RM
  def reference_recent_average
    rms = @records
            .recent_days(14)
            .map(&:estimated_one_rm)
            .compact

    return nil if rms.empty?
    rms.sum / rms.size
  end

  private

  def reference_one_rm
    @records
      .recent_days(14)
      .map(&:estimated_one_rm)
      .compact
      .max
  end

  def latest_one_rm
    @records.last&.estimated_one_rm
  end
end
