module Captain::Conversation::GenerationFailureReporting
  private

  def report_generation_failure(reason, details)
    Rails.logger.error(
      "[CAPTAIN][ResponseBuilderJob] Generation failed account=#{account.id} conversation=#{@conversation.display_id} " \
      "model=#{@assistant.agent_model} endpoint=#{Llm::Config.agents_api_base} reason=#{reason} details=#{details}"
    )
    return unless Rails.cache.write("captain_generation_failure_alert:#{account.id}", true, expires_in: 1.hour, unless_exist: true)

    AdministratorNotifications::AccountNotificationMailer.with(account: account)
                                                         .captain_generation_failed(@assistant.agent_model, reason).deliver_later
  end
end
