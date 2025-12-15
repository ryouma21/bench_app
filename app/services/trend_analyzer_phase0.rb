# app/services/trend_analyzer_phase0.rb
class TrendAnalyzerPhase0
  def initialize(records)
    @records = records
  end

  def trend
    return :flat if @records.blank?

    reference = reference_one_rm
    latest    = latest_one_rm

    return :flat if reference.nil? || latest.nil?
      # -5% 以内は維持
    if latest < reference * 0.95
      :down
    else
      :flat
    end
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
