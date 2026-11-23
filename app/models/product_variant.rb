# == Schema Information
#
# Table name: product_variants
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE), not null
#  currency   :string           default("DOP"), not null
#  name       :string           not null
#  price      :decimal(10, 2)   not null
#  sku        :string           not null
#  stock      :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_product_variants_on_account_id_and_sku  (account_id,sku) UNIQUE
#  index_product_variants_on_product_id          (product_id)
#
class ProductVariant < ApplicationRecord
  LOW_STOCK_THRESHOLD = 5

  belongs_to :product
  belongs_to :account

  before_validation { self.account_id ||= product&.account_id }
  before_validation { self.currency = self.class.app_currency }

  scope :active, -> { where(active: true) }

  validates :name, :sku, :currency, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sku, uniqueness: { scope: :account_id }

  # One currency for the whole app, set in Super Admin → Settings (DEFAULT_CURRENCY).
  def self.app_currency
    GlobalConfig.get_value('DEFAULT_CURRENCY').presence || 'DOP'
  end

  def availability
    return 'out_of_stock' unless stock.positive?

    stock <= LOW_STOCK_THRESHOLD ? 'low_stock' : 'in_stock'
  end
end
