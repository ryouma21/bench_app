class CreateTrainingRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :training_records do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :weight, null: false
      t.integer :reps, null: false
      t.integer :sets, null: false
      t.integer :total_volume
      t.integer :fatigue_level
      t.string :advice
      t.date :training_date, null: false

      t.timestamps
    end
  end
end
