# == Schema Information
#
# Table name: products
#
#  id                    :bigint           not null, primary key
#  active                :boolean          default(TRUE), not null
#  ai_description        :text
#  brand                 :string
#  category              :string           not null
#  description           :text
#  image_url             :string
#  name                  :string           not null
#  requires_prescription :boolean          default(FALSE), not null
#  sku                   :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  account_id            :bigint           not null
#
# Indexes
#
#  index_products_on_account_id_and_category  (account_id,category)
#  index_products_on_account_id_and_sku       (account_id,sku) UNIQUE
#
class Product < ApplicationRecord
  belongs_to :account
  has_many :variants, -> { order(:price) }, class_name: 'ProductVariant', dependent: :destroy_async, inverse_of: :product

  validates :name, :sku, :category, presence: true
  validates :sku, uniqueness: { scope: :account_id }

  accepts_nested_attributes_for :variants, allow_destroy: true

  SEARCH_COLUMNS = %w[name description ai_description brand category].freeze
  SEARCH_SQL = SEARCH_COLUMNS.map { |column| "products.#{column} ILIKE :p" }.join(' OR ').freeze
  WORD_SQL = SEARCH_COLUMNS.map { |column| "products.#{column} ~* :re" }.join(' OR ').freeze

  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where(id: ProductVariant.active.where('stock > 0').select(:product_id)) }
  scope :search, lambda { |term|
    pattern = "%#{sanitize_sql_like(term.to_s.delete("\0").strip)}%"
    where(SEARCH_SQL, p: pattern)
  }

  def self.filter_by(filters)
    scope = filters[:include_inactive] ? all : active
    scope = scope.search(filters[:q]) if filters[:q].present?
    scope = scope.where(category: filters[:category]) if filters[:category].present?
    scope = scope.in_stock if filters[:in_stock]
    scope
  end

  LOOKUP_STOPWORDS = %w[
    para tiene tienen mis sus una uno los las con por que del algo hay quiero necesito cual cuanto cuesta precio como donde
    usa usan uso hijo hija with have want need that this
  ].freeze

  # Fuzzy lookup used by the chat assistants: the whole phrase first, then products matching the most meaningful words.
  def self.lookup(query:, category: nil, limit: 5)
    scope = active.includes(:variants)
    scope = scope.where('products.category ILIKE ?', "%#{sanitize_sql_like(category.to_s.strip)}%") if category.present?
    scope.where(WORD_SQL, re: word_start(query)).limit(limit).to_a.presence || best_word_matches(scope, query, limit)
  end

  def self.word_start(term)
    "\\m#{Regexp.escape(term.to_s.strip)}"
  end

  def self.best_word_matches(scope, query, limit)
    terms = query.to_s.downcase.scan(/[[:alpha:]]+/).select { |term| term.length > 2 && LOOKUP_STOPWORDS.exclude?(term) }
    hits = terms.flat_map { |term| scope.where(WORD_SQL, re: word_start(term)).to_a }
    hits.tally.sort_by { |_product, count| -count }.first(limit).map(&:first)
  end
  private_class_method :best_word_matches

  def total_stock
    variants.select(&:active).sum(&:stock)
  end
end
