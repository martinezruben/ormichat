require 'rails_helper'

RSpec.describe Captain::Conversation::GenerationFailureReporting do
  let(:account) { Account.create!(name: 'Failure reporting') }
  let(:assistant) { instance_double(Captain::Assistant, agent_model: 'gpt-test') }
  let(:conversation) { instance_double(Conversation, display_id: 7) }
  let(:reporter) do
    Class.new do
      include Captain::Conversation::GenerationFailureReporting

      def initialize(account, assistant, conversation)
        @account = account
        @assistant = assistant
        @conversation = conversation
      end

      attr_reader :account

      def report(reason, details) = report_generation_failure(reason, details)
    end.new(account, assistant, conversation)
  end
  let(:memory_cache) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(Rails).to receive(:cache).and_return(memory_cache)
    allow(Rails.logger).to receive(:error)
  end

  it 'logs model and endpoint and alerts administrators once per window' do
    expect do
      reporter.report('boom', 'Resource not found')
      reporter.report('boom', 'Resource not found')
    end.to have_enqueued_mail(AdministratorNotifications::AccountNotificationMailer, :captain_generation_failed).once

    expect(Rails.logger).to have_received(:error).with(/model=gpt-test endpoint=\S+ reason=boom details=Resource not found/).twice
  end
end
