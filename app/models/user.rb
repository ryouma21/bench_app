class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true
  has_many :training_records

  def suggested_menu
    # 必ず training_date で並べ替える
    records = training_records.order(training_date: :asc)
    return nil if records.empty?

    # 最新の1RM（最後のレコードが最新）
    latest_1rm = records.last.estimated_one_rm

    # 記録が1つしかない場合は固定メニュー
    if records.count == 1
      return {
        percentage: 70,
        reps: 5,
        sets: 5,
        weight: (latest_1rm * 0.7).round
      }
    end

    # 過去3回の平均1RM
    average_1rm = average_last_three_1rm

    # 週間ボリューム
    weekly_volume = TrainingRecord.weekly_volume(self)

    ########################################
    # ★ ここから新ロジック(A+D)の追加部分
    ########################################

    # ① diff（差分：最新1RM - 過去3回平均）
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

    ########################################
    # ★ ここまでが新ロジックの追加部分
    ########################################
    # 条件分岐
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

    {
      percentage: percentage,
      reps: reps,
      sets: sets,
      weight: round_to_plate(latest_1rm * (percentage / 100.0))
    }
  end

  # ★ 過去3回の平均1RM（必ず training_date で並べ替える）
  def average_last_three_1rm
    records = training_records.order(training_date: :asc)
    return nil if records.size < 3

    last_three = records.last(3).map(&:estimated_one_rm)
    (last_three.sum / 3.0).round(1)
  end
  # 2.5kg刻みに丸める
  def round_to_plate(weight)
    (weight / 2.5).round * 2.5
  end
end