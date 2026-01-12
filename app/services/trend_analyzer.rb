class TrendAnalyzer
  def initialize(records)
    # records には valid_measurement_records（測定のみ・1日1件・nilなし）を入れる想定
    @records = records
    @one_rms = records.map(&:estimated_one_rm)
  end

  # 外部から呼ばれるメソッド
  def trend
    return :flat if @one_rms.size < 3  # データが3件未満なら判定不可

    last3 = @one_rms.last(3)
    a, b, c = last3

    # ---  強いトレンド判定（並びチェック）---
    return :up   if a < b && b < c
    return :down if a > b && b > c

    # ---  弱いトレンド判定（幅チェック）---
    range = last3.max - last3.min
# range が 2kg以内なら誤差として flat
    if range <= 2.0
      :flat
    elsif c > a
      :up
    elsif c < a
      :down
    else
      :flat
    end
  end
end
