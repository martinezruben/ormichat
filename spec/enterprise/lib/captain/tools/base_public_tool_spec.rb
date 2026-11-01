require 'rails_helper'

RSpec.describe Captain::Tools::BasePublicTool do
  let(:account) { Account.create!(name: 'Farmacia Test') }
  let(:assistant) { Captain::Assistant.create!(account: account, name: 'Asistente', description: 'Prueba') }

  {
    Captain::Tools::HandoffTool => { properties: %w[reason reason_category], required: ['reason_category'] },
    Captain::Tools::FaqLookupTool => { properties: %w[query], required: ['query'] },
    Captain::Tools::AddPrivateNoteTool => { properties: %w[note], required: ['note'] },
    Captain::Tools::ResolveConversationTool => { properties: %w[reason], required: ['reason'] }
  }.each do |tool_class, expected|
    it "declares the arguments of #{tool_class.name.demodulize} for the model" do
      schema = tool_class.new(assistant).parameters_schema

      expect(schema['properties'].keys).to match_array(expected[:properties])
      expect(schema['required']).to eq(expected[:required])
    end
  end
end
