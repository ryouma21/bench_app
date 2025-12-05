class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true
  has_many :training_records

  def suggested_menu
    # 1RM が入っている記録だけを対象にする（nilが混ざらない）
    valid_records = training_records
                  .select { |r| r.estimated_one_rm.present? }
                  .sort_by(&:training_date)
    # 記録がなければメニューは作れない
    return nil if valid_records.empty?

    # 最新の1RM（最後のレコードが最新）
    latest_1rm = valid_records.last.estimated_one_rm

    # 有効データが1件 → 差分が取れないので初回メニュー
    if valid_records.size == 1
      return {
        percentage: 70,
        reps: 5,
        sets: 5,
        weight: (latest_1rm * 0.7).round
      }
    end
    
    # 「直近3件」をまず取得（nil含む）
    recent_three = training_records
                    .sort_by(&:training_date)
                    .last(3)
    
    # その中で1RMが計算できるものだけ使う
    valid_recent_three = recent_three
                        .map(&:estimated_one_rm)
                        .compact
    
    # 比較できるデータが2件未満 → トレンド判定できない# 初回メニュー扱い（安全）
    if valid_recent_three.size < 2
      return {
        percentage: 70,
        reps: 5,
        sets: 5,
        weight: round_to_plate(latest_1rm * 0.7)
      }
    end

    # 過去3回の平均1RM
    average_1rm = (valid_recent_three.sum / valid_recent_three.size.to_f).round(1)
    
    # ① diff（差分：最新1RM - 平均）
    diff = latest_1rm - average_1rm

    # ② 誤差の範囲（普通のジムの最小プレート：2.5kg）
    threshold = 2.5

    # ③ トレンド判定（UP / DOWN / FLAT）
    trend =
      if diff >= threshold
        :up        # 調子いい
      elsif diff <= -threshold
        :down      # 調子悪い
      else
        :flat      # 誤差の範囲
      end

    # 週間ボリューム（nil安全）
    weekly_volume = TrainingRecord.weekly_volume(self) || 0

    # 条件分岐 メニューを決定
    case trend
    when :up
      # 調子良い → 攻めメニュー
      percentage = 80
      reps = 3
      sets = 3

    when :down
      # 調子悪い → 回復より・フォーム重視
      percentage = 70
      reps = 5
      sets = 5

    when :flat
      # 横ばい → ボリュームで判断
      if weekly_volume < 3000
        percentage = 75
        reps = 5
        sets = 5
      else
        percentage = 65
        reps = 6
        sets = 3
      end
    end
    # ⑩ 最終的な重量を返す（2.5kg刻みに丸める）
    {
      percentage: percentage,
      reps: reps,
      sets: sets,
      weight: round_to_plate(latest_1rm * (percentage / 100.0))
    }
  end

  # 2.5kg刻みに丸める
  def round_to_plate(weight)
    (weight / 2.5).round * 2.5
  end

  # 軽め（フォーム重視でやる）
  def suggested_lighter_menu
    base = suggested_menu
    return unless base

    {
      weight: (base[:weight] * 0.9).round,  # 10%軽く
      reps:   base[:reps] + 1,              # 回数を1増やす
      sets:   base[:sets]                   # セット数は同じ
    }
  end

  # 重め（刺激を入れてみる）ロジック
  def suggested_heavier_menu
    base = suggested_menu
    return unless base

    {
      weight: (base[:weight] * 1.05).round, # 5%重く
      reps:   [base[:reps] - 1, 1].max,     # 回数を1減らす（最低1回）
      sets:   base[:sets]
    }
  end


end