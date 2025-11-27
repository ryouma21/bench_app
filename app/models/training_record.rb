class TrainingRecord < ApplicationRecord
  belongs_to :user
  has_one :form_check

  validates :weight, :reps, :sets, :training_date, presence: true
  validates :weight, :reps, :sets, numericality: { greater_than: 0 }
end
