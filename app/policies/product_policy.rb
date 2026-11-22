class ProductPolicy < ApplicationPolicy
  def index?
    @account_user.administrator? || @account_user.agent?
  end

  def show?
    index?
  end

  def create?
    @account_user.administrator?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def upload_image?
    create?
  end

  def remove_image?
    create?
  end
end
