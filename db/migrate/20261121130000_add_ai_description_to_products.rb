class AddAiDescriptionToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :ai_description, :text
  end
end
