class CreateProducts < ActiveRecord::Migration[7.2]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :products do |t|
      t.references :account, null: false, index: false
      t.string :name, null: false
      t.string :sku, null: false
      t.string :category, null: false
      t.string :brand
      t.text :description
      t.string :image_url
      t.boolean :requires_prescription, null: false, default: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :products, [:account_id, :sku], unique: true
    add_index :products, [:account_id, :category]

    create_table :product_variants do |t|
      t.references :product, null: false, index: true
      t.references :account, null: false, index: false
      t.string :name, null: false
      t.string :sku, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: 'BOB'
      t.integer :stock, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :product_variants, [:account_id, :sku], unique: true
  end
  # rubocop:enable Metrics/MethodLength
end
