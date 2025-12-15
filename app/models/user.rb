class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true
  has_many :training_records

  # 2.5kg刻みに丸める
  def round_to_plate(weight)
    (weight / 2.5).round * 2.5
  end
end