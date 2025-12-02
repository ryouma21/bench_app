class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true
  has_many :training_records

  def suggested_menu
    # ① 記録が1つもない場合はメニューを作れない
    return nil if training_records.empty?

    # ② 最新の推定1RMを取得（最後の記録が最新）
    latest_1rm = training_records.last.estimated_one_rm

    # ③ 最新1RMの70%を計算（今日の提案重量）
    suggested_weight = (latest_1rm * 0.7).round

    # ④ 提案メニューをハッシュで返す
    {
      percentage: 70,
      reps: 5,
      sets: 5,
      weight: suggested_weight
    }
  end
end
