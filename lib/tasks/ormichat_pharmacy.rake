# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :ormichat do
  desc 'Crea la configuración base de farmacia: sucursales (equipos), etiquetas, atributos de cliente y reglas de receta y reacción adversa. ' \
       'Uso: ACCOUNT_ID=1 BRANCHES="Centro,Norte" rails ormichat:pharmacy_setup. Seguro de repetir.'
  task pharmacy_setup: :environment do
    account = ENV['ACCOUNT_ID'].present? ? Account.find(ENV.fetch('ACCOUNT_ID')) : Account.first!
    branches = ENV.fetch('BRANCHES', 'Sucursal principal').split(',').map(&:strip)

    # Team guarda el nombre en minúsculas: buscar con el nombre ya normalizado para que la tarea sea repetible.
    pharmacists = account.teams.find_or_create_by!(name: 'farmacéuticos') { |t| t.description = 'Atiende recetas y consultas clínicas' }
    branches.each { |name| account.teams.find_or_create_by!(name: name.downcase) { |t| t.description = 'Equipo de la sucursal' } }
    puts "✔ Equipos: Farmacéuticos + #{branches.join(', ')}"

    {
      'receta' => '#f59e0b', 'reaccion-adversa' => '#dc2626', 'consulta-clinica' => '#7c3aed',
      'domicilio' => '#0ea5e9', 'disponibilidad' => '#16a34a'
    }.each do |title, color|
      account.labels.find_or_create_by!(title: title) do |label|
        label.color = color
        label.show_on_sidebar = true
      end
    end
    puts '✔ Etiquetas: receta, reaccion-adversa, consulta-clinica, domicilio, disponibilidad'

    [
      ['sucursal_preferida', 'Sucursal preferida', :list, branches],
      ['consentimiento_contacto', 'Consentimiento de contacto', :checkbox, []],
      ['seguro', 'Seguro', :text, []],
      ['fidelidad', 'Programa de fidelidad', :text, []]
    ].each do |key, name, type, values|
      account.custom_attribute_definitions.find_or_create_by!(attribute_key: key, attribute_model: :contact_attribute) do |a|
        a.attribute_display_name = name
        a.attribute_display_type = type
        a.attribute_values = values
      end
    end
    puts '✔ Atributos de contacto: sucursal_preferida, consentimiento_contacto, seguro, fidelidad'

    # El motor encadena las condiciones con AND/OR en SQL y cada condición de contenido admite un solo valor,
    # por eso hay una regla por palabra clave. Solo mensajes entrantes; no detecta fotos sin texto.
    base_actions = lambda do |label, priority, note|
      [
        { action_name: 'add_label', action_params: [label] },
        { action_name: 'assign_team', action_params: [pharmacists.id] },
        { action_name: 'change_priority', action_params: [priority] },
        { action_name: 'add_private_note', action_params: [note] }
      ]
    end
    receta_note = 'Posible receta médica. No interpretarla ni dar dosis: derivar al farmacéutico.'
    reaccion_note = 'Posible reacción adversa a un medicamento. Escalar al farmacéutico de inmediato y registrar en farmacovigilancia.'
    keywords = { 'receta' => ['receta'], 'reaccion-adversa' => ['reacción', 'reaccion', 'alergia', 'efecto secundario', 'efectos secundarios'] }

    keywords.each do |label, words|
      words.each do |word|
        rule = account.automation_rules.find_or_initialize_by(name: "Farmacia: #{label} (#{word})")
        rule.update!(
          event_name: 'message_created',
          description: "Etiqueta #{label} y deriva a farmacéuticos cuando el cliente escribe \"#{word}\"",
          conditions: [
            { attribute_key: 'content', filter_operator: 'contains', values: [word], query_operator: 'AND' },
            { attribute_key: 'message_type', filter_operator: 'equal_to', values: ['incoming'], query_operator: nil }
          ],
          actions: label == 'receta' ? base_actions.call(label, 'high', receta_note) : base_actions.call(label, 'urgent', reaccion_note)
        )
      end
    end
    puts "✔ Reglas de automatización: #{keywords.values.flatten.size}"

    # Se agregan a las que ya tenga el asistente (ASSISTANT_ID para elegir uno existente), sin reemplazarlas.
    assistant = if ENV['ASSISTANT_ID'].present?
                  account.captain_assistants.find(ENV.fetch('ASSISTANT_ID'))
                else
                  account.captain_assistants.find_or_create_by!(name: 'Asistente de farmacia') do |a|
                    a.description = 'Atiende consultas generales de la farmacia: horarios, sucursales, domicilios y pedidos.'
                  end
                end
    guardrails = [
      'Nunca diagnostiques, recomiendes tratamientos, indiques dosis ni sugieras cambiar un medicamento por otro. Deriva siempre al farmacéutico.',
      'No interpretes recetas médicas ni fotos de recetas: confirma que las recibiste y deriva la conversación al farmacéutico.',
      'Si el cliente menciona una reacción adversa, alergia, síntomas graves o una emergencia, dile que acuda a urgencias si es grave y ' \
      'pasa la conversación a una persona de inmediato.',
      'No confirmes disponibilidad, precios ni plazos que no estén en tus fuentes o herramientas; si no los tienes, dilo y deriva.',
      'No pidas datos de salud innecesarios (diagnósticos, historial clínico) ni los repitas en la conversación.'
    ]
    guidelines = [
      'Responde en español, con tono amable y breve, salvo que el cliente escriba en inglés.',
      'Si la respuesta depende de la ubicación, pregunta primero la sucursal de preferencia del cliente.',
      'Si no puedes resolver la consulta, avisa que pasarás la conversación a una persona del equipo.'
    ]
    assistant.update!(guardrails: ((assistant.guardrails || []) + guardrails).uniq,
                      response_guidelines: ((assistant.response_guidelines || []) + guidelines).uniq)
    puts "✔ Asistente \"#{assistant.name}\": #{assistant.guardrails.size} reglas de seguridad y #{assistant.response_guidelines.size} pautas"
  end
end
# rubocop:enable Metrics/BlockLength
