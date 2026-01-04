class HomeController < ApplicationController
  def index
    return unless user_signed_in?

    # 0) 最後の測定日を取得（training_date基準）
    last_measurement_date =
      current_user.training_records.measurement.maximum(:training_date)

    # 1) 7日以上空いてたら true（=ボタン表示）
    @show_measurement_button =
      last_measurement_date.nil? || last_measurement_date <= 7.days.ago.to_date

    # 2) 表示メッセージ
    if last_measurement_date.nil?
      @measurement_recommendation = "まずは測定用（1〜3回）の記録を1回追加すると、メニューを安定して作れます。"
    elsif @show_measurement_button
      days = (Date.current - last_measurement_date).to_i
      @measurement_recommendation = "前回の測定から#{days}日経ちました。目安：週1回（7日）で測定しましょう。"
    else
      @measurement_recommendation = nil
    end

    # ① valid_records を取得（TrainingRecordモデルのスコープを使用）
    records = current_user.training_records.valid_measurement_records

    # 記録がゼロ or 1RMがない → メニュー作成不可
    if records.blank?
      @today_menu = nil
      @measurement_recommendation = "まずは測定用（1〜3回）の記録を1回追加すると、メニューを安定して作れます。"
      return
    end

    # ② トレンドを計算
    analyzer = TrendAnalyzerPhase0.new(records)
    trend = analyzer.trend

    # ③ 最新の1RMを取り出す
    latest_one_rm = records.last.estimated_one_rm

    # 直近14日間の平均1RMを基準値として使用する
    # ※ 有効な1RMが十分に取れない場合は、無理にメニューを出さず nil にする
    reference_one_rm = analyzer.reference_recent_average

    # 基準となる平均1RMが取得できない場合
    # （記録不足・直近に有効な1RMがない等）は安全のためメニューを表示しない
    if reference_one_rm.nil?
      @today_menu = nil
      return
    end

    # ⑤ 今日のメニューを生成
    @today_menu = MenuGenerator.new(
      latest_one_rm: latest_one_rm,
      reference_one_rm: reference_one_rm,
      trend: trend
    ).menu

    # ★ フェーズ0用メッセージ
    @trend_message = analyzer.message
  end
end
