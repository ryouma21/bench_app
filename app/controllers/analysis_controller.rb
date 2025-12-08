class AnalysisController < ApplicationController
  def index
    # ① 過去の記録
    records = current_user.training_records
              .latest_valid_per_day
              .order(training_date: :desc)
              .last(5)

    # ② 1RM配列
    @one_rm_values = records.map { |r| r.estimated_one_rm }.compact

    # ③ 日付配列
    @one_rm_dates = records.map { |r| r.training_date.strftime("%Y/%m/%d") }

    # ④ 週間総ボリューム（直近7日分）
    one_week_records = current_user.training_records
                                  .where("training_date >= ?", 7.days.ago)

    @weekly_volume = one_week_records.sum(&:total_volume)

    # ★ 今日のおすすめメニューを計算
    @today_menu = current_user.suggested_menu
  end
end
