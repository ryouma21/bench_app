class TrainingRecord < ApplicationRecord
  belongs_to :user
  # has_one :form_check, dependent: :destroy

  before_save :set_total_volume

  # 推定1RM を Epley式で計算するメソッド
  # 1RM = weight * (1 + reps / 30)
  def estimated_one_rm
    # 重量か回数が入っていなかったら計算できないので nil を返す
    return nil if weight.blank? || reps.blank?

    # reps.to_f として小数計算にする（整数同士だと割り算がズレるため）
    one_rm = weight * (1 + reps.to_f / 30)

    # 小数第1位までに丸める（例：93.333... → 93.3）
    one_rm.round(1)
  end

  private

  def set_total_volume
    self.total_volume = weight.to_i * reps.to_i * sets.to_i
  end

  validates :weight, :reps, :sets, :training_date, presence: true
  validates :weight, :reps, :sets, numericality: { greater_than: 0 }
end
