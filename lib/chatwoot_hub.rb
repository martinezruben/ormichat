# Datos locales de la instalación. Ormichat no se comunica con servicios de Chatwoot.
class ChatwootHub
  def self.installation_identifier
    identifier = InstallationConfig.find_by(name: 'INSTALLATION_IDENTIFIER')&.value
    identifier ||= InstallationConfig.create!(name: 'INSTALLATION_IDENTIFIER', value: SecureRandom.uuid).value
    identifier
  end

  def self.pricing_plan
    return 'community' unless ChatwootApp.enterprise?

    InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')&.value || 'community'
  end

  def self.pricing_plan_quantity
    return 0 unless ChatwootApp.enterprise?

    InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY')&.value || 0
  end
end
