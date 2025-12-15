class HomeController < ApplicationController
  def index
  return unless user_signed_in?

  # ① valid_records を取得（TrainingRecordモデルのスコープを使用）
  records = current_user.training_records.valid_records

  # 記録がゼロ or 1RMがない → メニュー作成不可
  if records.blank? || records.last.estimated_one_rm.nil?
    @today_menu = nil
    return
  end

  # ② トレンドを計算
  trend = TrendAnalyzerPhase0.new(records).trend

  # ③ 最新の1RMを取り出す
  latest_one_rm = records.last.estimated_one_rm

  # ④ 今日のメニューを生成
  @today_menu = MenuGenerator.new(latest_one_rm, trend).menu
  end
end
