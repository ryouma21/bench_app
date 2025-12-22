class AddSetTypeToTrainingRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :training_records, :set_type, :integer, null: false, default: 1
    add_index  :training_records, :set_type
  end
end
