class AddSelectableToLabels < ActiveRecord::Migration[7.2]
  def change
    add_column :labels, :selectable, :boolean, default: true, null: false
  end
end
