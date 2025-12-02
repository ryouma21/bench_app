class AnalysisController < ApplicationController
  def index
    # ① 過去の記録
    @training_records = current_user.training_records.order(training_date: :asc)

    # ② 1RM配列
    @one_rm_values = @training_records.map { |r| r.estimated_one_rm }.compact

    # ③ 日付配列
    @one_rm_dates = @training_records.map { |r| r.training_date.strftime("%Y/%m/%d") }

    # ④ 週間総ボリューム
    @weekly_volume = TrainingRecord.weekly_volume(current_user)
  end
end
