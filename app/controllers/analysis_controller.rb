class AnalysisController < ApplicationController
  def index
    # ① グラフ用：1日1件の記録（直近5日）
    graph_records = current_user.training_records
                                .valid_measurement_records 
                                .order(training_date: :desc)
                                .limit(5)
                                .reverse

    # ② 1RM配列
    @one_rm_values = graph_records.map(&:estimated_one_rm).compact

    # ③ 日付配列
    @one_rm_dates = graph_records.map { |r| r.training_date.strftime("%Y/%m/%d") }

    # ④ 週間総ボリューム（直近7日分）
    one_week_records = current_user.training_records
                                   .where(training_date:  6.days.ago.to_date..Date.current)

    @weekly_volume = one_week_records
    .where.not(weight: nil, reps: nil, sets: nil)
    .sum("weight * reps * sets")
  end
end
