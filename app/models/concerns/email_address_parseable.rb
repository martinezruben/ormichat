module EmailAddressParseable
  extend ActiveSupport::Concern

  private

  def parse_email(email_string)
    Mail::Address.new(email_string).address.presence || default_sender_email_address
  rescue Mail::Field::ParseError, Mail::Field::IncompleteParseError
    default_sender_email_address
  end

  def default_sender_email_address
    Mail::Address.new(ChatwootApp.mailer_sender_email).address
  end
end
