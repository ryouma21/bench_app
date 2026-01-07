class TrainingRecord < ApplicationRecord
  belongs_to :user

  enum set_type: { measurement: 0, volume: 1 }
  enum menu_type: { free: 0, normal: 1, lighter: 2, heavier: 3 }

  before_validation :set_default_menu_type, on: :create
  def set_default_menu_type
    self.menu_type = :free if menu_type.blank?
  end

  scope :measurement_records, -> { where(set_type: :measurement) }
  scope :volume_records,      -> { where(set_type: :volume) }

  # has_one :form_check, dependent: :destroy

  before_save :set_total_volume

  # 推定1RM を Epley式で計算するメソッド
  # 1RM = weight * (1 + reps / 30)
  def estimated_one_rm
    # 重量か回数が入っていなかったら計算できないので nil を返す
    return nil if weight.blank? || reps.blank?
    raw = weight * (1 + reps.to_f / 30)
    self.class.round_to_plate(raw)
  end

  # 2.5kg刻みに丸める（共通ルール）
  PLATE = 2.5

  def self.round_to_plate(value, plate = PLATE)
    return nil if value.nil?
    ((value.to_f / plate).round) * plate
  end


  # =========================
  #  分析用スコープ群
  # =========================
  #  # weight / reps が入っている記録のみ
  scope :with_one_rm, -> {
    where.not(weight: nil, reps: nil)
      .where("weight >= 30")
  }
  # 1日1件（最新）のみ抽出（ユーザー単位で）
  scope :latest_per_day, -> {
    select("training_records.*")
      .joins(<<~SQL)
        INNER JOIN (
          SELECT user_id, training_date, MAX(created_at) AS max_created_at
          FROM training_records
          WHERE weight IS NOT NULL
            AND reps IS NOT NULL
            AND weight >= 30
          GROUP BY user_id, training_date
        ) AS daily
        ON training_records.user_id = daily.user_id
        AND training_records.training_date = daily.training_date
        AND training_records.created_at = daily.max_created_at
      SQL
  }
  # 分析に使う「クリーンな記録」
  scope :valid_records, -> {
     latest_per_day
    .where.not(weight: nil, reps: nil)
    .order(:training_date)
  }

  # 測定（measurement）だけを分析に使うためのスコープ（ユーザー単位で）
  scope :latest_measurement_per_day, -> {
    measurement_value = TrainingRecord.set_types[:measurement] # => 0

    select("training_records.*")
      .joins(<<~SQL)
        INNER JOIN (
          SELECT user_id, training_date, MAX(created_at) AS max_created_at
          FROM training_records
          WHERE weight IS NOT NULL
            AND reps IS NOT NULL
            AND weight >= 30
            AND set_type = #{measurement_value}
          GROUP BY  user_id, training_date
        ) AS daily
        ON training_records.user_id = daily.user_id
        AND training_records.training_date = daily.training_date
        AND training_records.created_at = daily.max_created_at
      SQL
      .where(set_type: :measurement)
}
# 分析で扱いやすい形（並び順）にする
scope :valid_measurement_records, -> {
  latest_measurement_per_day.order(:training_date)
}

  # ===============================
  # 補助ロジック
  # ===============================
  def self.weekly_volume(user)
    # 過去7日間の total_volume の合計を返す
    where(user: user, training_date: 7.days.ago.to_date..Date.today)
    .sum(:total_volume)
  end
  # 直近◯日分
  scope :recent_days, ->(days) {
    where(training_date: days.days.ago.to_date..Date.today)
  }

  private

  def set_total_volume
    self.total_volume = weight.to_i * reps.to_i * sets.to_i
  end

  validates :weight, :reps, :sets, :training_date, presence: true
  validates :weight, :reps, :sets, numericality: { greater_than: 0 }
end
