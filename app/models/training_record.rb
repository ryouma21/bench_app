class TrainingRecord < ApplicationRecord
  belongs_to :user
  has_one :form_check, dependent: :destroy

  validates :weight, :reps, :sets, :training_date, presence: true
  validates :weight, :reps, :sets, numericality: { greater_than: 0 }
end
