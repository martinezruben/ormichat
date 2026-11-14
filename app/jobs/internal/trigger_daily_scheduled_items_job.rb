class Internal::TriggerDailyScheduledItemsJob < ApplicationJob
  queue_as :scheduled_jobs

  # Punto de extensión para tareas diarias; enterprise programa aquí la sincronización de documentos de Captain.
  def perform; end
end

Internal::TriggerDailyScheduledItemsJob.prepend_mod_with('Internal::TriggerDailyScheduledItemsJob')
