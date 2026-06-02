class AlterDatabaseCharsetAndCollation < ActiveRecord::Migration[8.1]
  # Convert the database default charset and collation to utf8mb4 charset with utf8mb4_unicode_ci collation
  def up
    execute "ALTER DATABASE #{connection.current_database} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
  end

  # Revert the database default charset and collation to latin1 charset with latin1_swedish_ci collation
  def down
    execute "ALTER DATABASE #{connection.current_database} CHARACTER SET latin1 COLLATE latin1_swedish_ci"
  end
end
