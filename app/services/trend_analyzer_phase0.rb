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

    if latest < reference * 0.95
      :down
    else
      :flat
    end
  end

  private

  def reference_one_rm
    @records
      .select { |r| r.training_date >= 14.days.ago.to_date }
      .map(&:estimated_one_rm)
      .compact
      .max
  end

  def latest_one_rm
    @records.last&.estimated_one_rm
  end
end
