class DefaultProductCurrencyToDop < ActiveRecord::Migration[7.2]
  def up
    change_column_default :product_variants, :currency, from: 'BOB', to: 'DOP'
    execute("UPDATE product_variants SET currency = 'DOP'")
  end

  def down
    change_column_default :product_variants, :currency, from: 'DOP', to: 'BOB'
  end
end
