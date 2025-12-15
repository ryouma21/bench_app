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

  # =========================
  #  分析用スコープ群
  # =========================
  #  # weight / reps が入っている記録のみ
  scope :with_one_rm, -> {
    where.not(weight: nil, reps: nil)
      .where("weight >= 30")
  }
  # 1日1件（最新）のみ抽出
  scope :latest_per_day, -> {
    select("training_records.*")
      .joins(<<~SQL)
        INNER JOIN (
          SELECT training_date, MAX(created_at) AS max_created_at
          FROM training_records
          WHERE weight IS NOT NULL
            AND reps IS NOT NULL
            AND weight >= 30
          GROUP BY training_date
        ) AS daily
        ON training_records.training_date = daily.training_date
        AND training_records.created_at = daily.max_created_at
      SQL
  }
  # 分析に使う「クリーンな記録」
  scope :valid_records, -> {
    with_one_rm.latest_per_day
  }

# ------- フェーズ0用 基準1RM-------
  # 直近14日以内の最高1RM（下がらない基準）
  scope :reference_one_rm, -> {
    where(training_date: 14.days.ago.to_date..Date.today)
      .map(&:estimated_one_rm)
      .compact
      .max
  }
  
  # ===============================
  # 補助ロジック
  # ===============================
  def self.weekly_volume(user)
    # 過去7日間の total_volume の合計を返す
    where(user: user, training_date: 7.days.ago.to_date..Date.today)
    .sum(:total_volume)
  end

  private

  def set_total_volume
    self.total_volume = weight.to_i * reps.to_i * sets.to_i
  end

  validates :weight, :reps, :sets, :training_date, presence: true
  validates :weight, :reps, :sets, numericality: { greater_than: 0 }
end
