class MenusController < ApplicationController
  before_action :authenticate_user!

  def lighter
    render json: build_menu(:lighter)
  end

  def heavier
    render json: build_menu(:heavier)
  end

  private

  def build_menu(intensity)
    records = current_user.training_records.measurement_records.valid_records
    return {} if records.blank? || records.last&.estimated_one_rm.nil?

    analyzer = TrendAnalyzerPhase0.new(records)
    trend = analyzer.trend

    latest_one_rm = records.last.estimated_one_rm
    reference_one_rm = analyzer.reference_recent_average
    return {} if reference_one_rm.nil?

    MenuGenerator.new(
      latest_one_rm: latest_one_rm,
      reference_one_rm: reference_one_rm,
      trend: trend
    ).menu(intensity)
  end
end

