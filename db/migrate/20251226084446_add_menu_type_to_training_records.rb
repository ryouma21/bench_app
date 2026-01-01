class AddMenuTypeToTrainingRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :training_records, :menu_type, :integer, null: false, default: 0
    add_index  :training_records, :menu_type
  end
end
