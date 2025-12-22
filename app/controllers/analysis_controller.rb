class AnalysisController < ApplicationController
  def index
    # ① グラフ用：1日1件の記録（直近5日）
    graph_records = current_user.training_records
                                .latest_per_day
                                .order(training_date: :desc)
                                .limit(5)
                                .reverse

    # ② 1RM配列
    @one_rm_values = graph_records.map(&:estimated_one_rm).compact

    # ③ 日付配列
    @one_rm_dates = graph_records.map { |r| r.training_date.strftime("%Y/%m/%d") }

    # ④ 週間総ボリューム（直近7日分）
    one_week_records = current_user.training_records
                                   .where("training_date >= ?", 7.days.ago.to_date)

    @weekly_volume = one_week_records.sum(&:total_volume)

    # ⑤ 今日のおすすめメニュー（Homeと同じロジック）
    menu_records = current_user.training_records.valid_records

    if menu_records.blank? || menu_records.last.estimated_one_rm.nil?
      @today_menu = nil
      @trend_message = nil
      return
    end

    analyzer = TrendAnalyzerPhase0.new(menu_records)
    trend = analyzer.trend

    latest_one_rm = menu_records.last.estimated_one_rm
    reference_one_rm = analyzer.reference_recent_average

    if reference_one_rm.nil?
      @today_menu = nil
      @trend_message = nil
      return
    end

    @today_menu = MenuGenerator.new(
      latest_one_rm: latest_one_rm,
      reference_one_rm: reference_one_rm,
      trend: trend
    ).menu

    @trend_message = analyzer.message
  end
end
