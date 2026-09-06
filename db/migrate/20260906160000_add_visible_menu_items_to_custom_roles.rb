class AddVisibleMenuItemsToCustomRoles < ActiveRecord::Migration[7.2]
  def change
    add_column :custom_roles, :visible_menu_items, :text, array: true, default: [], null: false
  end
end
