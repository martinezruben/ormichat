class ResetUnsupportedAccountLocales < ActiveRecord::Migration[7.2]
  # Solo se soportan inglés (0) y español (12); las cuentas con otro idioma pasan a español.
  def up
    execute 'UPDATE accounts SET locale = 12 WHERE locale NOT IN (0, 12)'
  end

  def down; end
end
