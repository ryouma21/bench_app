class MenusController < ApplicationController
  def lighter
    render json: current_user.suggested_lighter_menu
  end

  def heavier
    render json: current_user.suggested_heavier_menu
  end

  def todays_menu
  # 1. valid_records を取る
  records = current_user.training_records.valid_records

  # 2. トレンドを判定
  trend = TrendAnalyzer.new(records).trend

  # 3. 最新1RM取得
  latest_one_rm = records.last.estimated_one_rm

  # 4. 今日のメニューを生成
  @today_menu = MenuGenerator.new(latest_one_rm, trend).menu
  end
end
