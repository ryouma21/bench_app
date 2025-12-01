class TrainingRecord < ApplicationRecord
  belongs_to :user
  # has_one :form_check, dependent: :destroy

  before_save :set_total_volume

  private

  def set_total_volume
    self.total_volume = weight.to_i * reps.to_i * sets.to_i
  end

  validates :weight, :reps, :sets, :training_date, presence: true
  validates :weight, :reps, :sets, numericality: { greater_than: 0 }
end
