class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true
  has_many :training_records

  def suggested_menu
    # 記録が1つもない場合はメニューを作れない
    return nil if training_records.empty?

    # 最新の推定1RMを取得（最後の記録が最新）
    latest_1rm = training_records.last.estimated_one_rm

     # 1つ前の記録がなければ（＝今回が初回）提案メニューをハッシュで返す
    if training_records.count == 1
      return {
        percentage: 70,
        reps: 5,
        sets: 5,
        weight: (latest_1rm * 0.7).round
      }
    end

    # 平均の1RM（過去3回）
    average_1rm = average_last_three_1rm

    # 過去7日間のボリューム
    weekly_volume = TrainingRecord.weekly_volume(self)

    # -------------------------
    # 条件分岐（基礎バージョン）
    # -------------------------

    # ① 1RMが伸びている → 重め
    if latest_1rm > average_1rm
      percentage = 80
      reps = 3
      sets = 3

    # ② 1RMが落ちている → 軽め
    elsif latest_1rm < average_1rm
      percentage = 70
      reps = 5
      sets = 5

    else
      # 1RM横ばいのとき
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

    # 最終的に重量を計算
    weight = (latest_1rm * (percentage / 100.0)).round

    # 結果を返す
    {
      percentage: percentage,
      reps: reps,
      sets: sets,
      weight: weight
    }
  end

  def average_last_three_1rm
    # 記録が3つ未満なら平均が出せないので nil
    return nil if training_records.size < 3

    # 最新3回の1RMだけ取り出す
    last_three = training_records.last(3).map(&:estimated_one_rm)

    # 平均を返す（小数第1位で丸める）
    (last_three.sum / 3.0).round(1)
  end
end
