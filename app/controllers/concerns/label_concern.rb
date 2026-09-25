module LabelConcern
  def create
    restricted_labels = non_selectable_new_labels
    return render_could_not_create_error(I18n.t('errors.labels.not_selectable', labels: restricted_labels.join(', '))) if restricted_labels.any?

    model.update_labels(permitted_params[:labels])
    @labels = model.label_list
  end

  def index
    @labels = model.label_list
  end

  private

  # Non-selectable labels are reserved for automations: agents can keep or
  # remove them, but only bots (and internal automation services) add them.
  def non_selectable_new_labels
    return [] unless Current.user.is_a?(User)

    new_labels = Array(permitted_params[:labels]).map(&:downcase) - model.label_list
    return [] if new_labels.empty?

    Current.account.labels.where(title: new_labels, selectable: false).pluck(:title)
  end
end
