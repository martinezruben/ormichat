# frozen_string_literal: true

require 'agents'

Rails.application.config.after_initialize do
  api_key = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_API_KEY')&.value
  model = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_MODEL')&.value.presence || LlmConstants::DEFAULT_MODEL

  if api_key.present?
    # ruby_llm 2.x envía las instrucciones con el rol `developer`; los servidores compatibles esperan `system`.
    RubyLLM.configure { |config| config.openai_use_system_role = true }

    Agents.configure do |config|
      config.openai_api_key = api_key
      config.openai_protocol = LlmConstants::OPENAI_COMPATIBLE_PROTOCOL
      config.openai_api_base = Llm::Config.agents_api_base
      config.default_model = model
      config.debug = false
    end
  end
rescue StandardError => e
  Rails.logger.error "Failed to configure AI Agents SDK: #{e.message}"
end
