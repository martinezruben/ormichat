require 'rails_helper'
require 'rake'

RSpec.describe 'ormichat:pharmacy_setup', type: :task do
  let(:account) { Account.create!(name: 'Farmacia Test') }
  let(:task) { Rake::Task['ormichat:pharmacy_setup'] }

  before do
    Rails.application.load_tasks unless Rake::Task.task_defined?('ormichat:pharmacy_setup')
    task.reenable
    ENV['ACCOUNT_ID'] = account.id.to_s
    ENV['BRANCHES'] = 'Centro,Norte'
  end

  after do
    ENV.delete('ACCOUNT_ID')
    ENV.delete('BRANCHES')
  end

  def run_task
    task.reenable
    expect { task.invoke }.to output(/Asistente/).to_stdout
  end

  it 'creates teams, labels, contact attributes, automation rules and a safe assistant' do
    run_task

    expect(account.teams.pluck(:name)).to contain_exactly('farmacéuticos', 'centro', 'norte')
    expect(account.labels.pluck(:title)).to include('receta', 'reaccion-adversa')
    expect(account.custom_attribute_definitions.contact_attribute.pluck(:attribute_key))
      .to contain_exactly('sucursal_preferida', 'consentimiento_contacto', 'seguro', 'fidelidad')
    expect(account.automation_rules.count).to eq(6)
    expect(account.captain_assistants.find_by(name: 'Asistente de farmacia').guardrails.join(' ')).to include('Nunca diagnostiques')
  end

  it 'is safe to run twice' do
    run_task
    counts = [account.teams.count, account.labels.count, account.automation_rules.count, account.captain_assistants.sole.guardrails.size]

    run_task

    expect([account.teams.count, account.labels.count, account.automation_rules.count, account.captain_assistants.sole.guardrails.size]).to eq(counts)
  end

  describe 'stock lookup tool' do
    let(:stock_tool) { account.captain_custom_tools.find_by(slug: 'consulta_stock') }

    after do
      ENV.delete('STOCK_API_URL')
      ENV.delete('STOCK_API_TOKEN')
    end

    it 'is not created without STOCK_API_URL' do
      run_task

      expect(stock_tool).to be_nil
    end

    it 'is created from the pharmacy API URL, with the token and its parameters' do
      ENV['STOCK_API_URL'] = 'https://api.farmacia.test/stock?producto={{ producto }}&sucursal={{ sucursal }}'
      ENV['STOCK_API_TOKEN'] = 'secreto'
      run_task

      expect(stock_tool).to have_attributes(enabled: true, auth_type: 'bearer', http_method: 'GET')
      expect(stock_tool.auth_config).to eq('token' => 'secreto')
      expect(stock_tool.param_schema.pluck('name', 'required')).to eq([['producto', true], ['sucursal', false]])
    end

    it 'is not duplicated when the task runs again' do
      ENV['STOCK_API_URL'] = 'https://api.farmacia.test/stock?producto={{ producto }}'
      run_task
      run_task

      expect(account.captain_custom_tools.where(slug: 'consulta_stock').count).to eq(1)
    end
  end

  describe 'automation rules' do
    let(:inbox) do
      channel = Channel::WebWidget.create!(account: account, website_url: 'https://farmacia.test')
      Inbox.create!(account: account, channel: channel, name: 'Web')
    end
    let(:contact) { Contact.create!(account: account, name: 'Cliente') }
    let(:conversation) do
      contact_inbox = ContactInbox.create!(contact: contact, inbox: inbox, source_id: SecureRandom.uuid)
      Conversation.create!(account: account, inbox: inbox, contact: contact, contact_inbox: contact_inbox)
    end

    before { run_task }

    def matching_rules(content, message_type: :incoming)
      message = conversation.messages.create!(account: account, inbox: inbox, content: content, message_type: message_type, sender: contact)
      account.automation_rules.select do |rule|
        AutomationRules::ConditionsFilterService.new(rule, conversation, { message: message }).perform
      end.map(&:name)
    end

    it 'flags a prescription mention, ignoring case' do
      expect(matching_rules('Les envío mi Receta médica')).to eq(['Farmacia: receta (receta)'])
    end

    it 'flags adverse reactions with and without accent' do
      expect(matching_rules('Me dio una Reacción rara')).to eq(['Farmacia: reaccion-adversa (reacción)'])
      expect(matching_rules('tengo alergia a la penicilina')).to eq(['Farmacia: reaccion-adversa (alergia)'])
    end

    it 'ignores ordinary questions and the agent own messages' do
      expect(matching_rules('¿Tienen paracetamol?')).to be_empty
      expect(matching_rules('Adjunte su receta', message_type: :outgoing)).to be_empty
    end
  end
end
