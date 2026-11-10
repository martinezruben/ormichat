# Campo de búsqueda para asociaciones belongs_to del panel de superadmin.
# Código de administrate-field-belongs_to_search 0.10.0 (MIT, https://github.com/fishbrain/administrate-field-belongs_to_search),
# incorporado porque la gema limita rails < 8.0. Los parciales, el JS y la vista JSON viven en app/.
require 'administrate/field/belongs_to'

module Administrate
  module Field
    class BelongsToSearch < Administrate::Field::BelongsTo
      def associated_resource_options
        return [] if data.nil?

        [[display_candidate_resource(data), data.id]]
      end
    end
  end
end

Administrate::Engine.add_javascript 'belongs_to_search.js'
