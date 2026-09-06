class Api::V1::Accounts::Contacts::DirectUploadsController < ActiveStorage::DirectUploadsController
  include DeviseTokenAuth::Concerns::SetUserByToken
  include RequestExceptionHandler
  include EnsureCurrentAccountHelper

  around_action :handle_with_exception
  before_action :authenticate_user!
  before_action :current_account
  before_action :contact

  def create
    return if @contact.nil? || @current_account.nil?

    super
  end

  private

  def contact
    @contact ||= Current.account.contacts.find_by(id: params[:contact_id])
  end
end
