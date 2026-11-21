class Api::V1::Accounts::ProductsController < Api::V1::Accounts::BaseController
  RESULTS_PER_PAGE = 25

  before_action :fetch_product, only: [:show, :update, :destroy]
  before_action :check_authorization

  def index
    scope = Current.account.products.includes(:variants).filter_by(filter_params).order(:category, :name)

    @products_count = scope.count
    @products = scope.page(params[:page] || 1).per(RESULTS_PER_PAGE)
  end

  def show; end

  def create
    @product = Current.account.products.create!(product_params)
    render :show, status: :created
  end

  def update
    @product.update!(product_params)
    render :show
  end

  def destroy
    @product.destroy!
    head :ok
  end

  private

  def fetch_product
    @product = Current.account.products.find(params[:id])
  end

  def filter_params
    boolean = ActiveModel::Type::Boolean.new
    {
      q: params[:q], category: params[:category],
      in_stock: boolean.cast(params[:in_stock]), include_inactive: boolean.cast(params[:include_inactive])
    }
  end

  def product_params
    params.require(:product).permit(
      :name, :sku, :category, :brand, :description, :image_url, :requires_prescription, :active,
      variants_attributes: [:id, :name, :sku, :price, :currency, :stock, :active, :_destroy]
    )
  end
end
