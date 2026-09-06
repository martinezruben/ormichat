# Applies the currently-stored SMTP settings inside a Sidekiq worker
# process. Triggered on demand (the "Reload configuration" button) since
# the web process applying the change to its own ActionMailer state has no
# way to reach the separate Sidekiq process that actually delivers mail.
class ReloadMailerSettingsJob < ApplicationJob
  queue_as :critical

  def perform
    MailerSettingsService.apply!
  end
end
