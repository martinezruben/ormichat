# Los logos de marca cambiaron de nombre para que navegadores y proxies no sigan
# sirviendo la versión anterior (se cachean un año). Solo se actualizan las
# instalaciones que conservan la ruta por defecto, no las que subieron su propio logo.
class PointBrandLogosToOrmichatFiles < ActiveRecord::Migration[7.2]
  RENAMED = {
    'LOGO' => ['/brand-assets/logo.svg', '/brand-assets/ormichat-logo.svg'],
    'LOGO_DARK' => ['/brand-assets/logo_dark.svg', '/brand-assets/ormichat-logo-dark.svg'],
    'LOGO_THUMBNAIL' => ['/brand-assets/logo_thumbnail.svg', '/brand-assets/ormichat-icon.svg']
  }.freeze

  def up
    RENAMED.each do |name, (old_path, new_path)|
      config = InstallationConfig.find_by(name: name)
      next unless config&.value == old_path

      config.update!(value: new_path)
    end
    GlobalConfig.clear_cache
  end

  def down; end
end
