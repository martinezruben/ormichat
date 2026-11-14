/* global $ */
// Campo belongs_to_search del panel de superadmin: selectize con búsqueda remota.
// Basado en administrate-field-belongs_to_search 0.10.0 (MIT).
$(() => {
  $('.field-unit--belongs-to-search select').each((_index, element) => {
    const $element = $(element);
    $element.selectize({
      valueField: 'id',
      labelField: 'dashboard_display_name',
      searchField: 'dashboard_display_name',
      create: false,
      searchUrl: `${$element.data('url')}?search=`,
      load(query, callback) {
        if (!query.length) {
          callback();
          return;
        }
        $.ajax({
          url: `${this.settings.searchUrl}${encodeURIComponent(query)}`,
          type: 'GET',
          error: () => callback(),
          success: response => callback(response.resources),
        });
      },
    });
  });
});
