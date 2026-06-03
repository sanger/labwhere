# frozen_string_literal: true

# Sets the database default charset to utf8mb4 and collation to utf8mb4_unicode_ci,
# so that new tables inherit them unless overridden explicitly.
#
# The original charset and collation are captured before the change and stored in
# ar_internal_metadata so that the migration can be safely reverted per environment.
#
# Note: MySQL implicitly commits any pending transaction before executing DDL,
# and commits the DDL itself upon success. The metadata write is therefore
# placed after the DDL to ensure it is only recorded if the DDL succeeded.
class AlterDatabaseCharsetAndCollation < ActiveRecord::Migration[8.1]
  # Convert the database default charset and collation to utf8mb4 and utf8mb4_unicode_ci.
  def up
    db_name = connection.current_database
    original = connection.select_one(
      'SELECT DEFAULT_CHARACTER_SET_NAME AS charset, DEFAULT_COLLATION_NAME AS collation ' \
      "FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = #{connection.quote(db_name)}"
    )
    # MySQL no-op if already set to utf8mb4 and utf8mb4_unicode_ci.
    execute "ALTER DATABASE #{connection.quote_table_name(db_name)} " \
            'CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci'

    # Guard against manual re-runs overwriting the recorded original values.
    return if internal_metadata[metadata_key].present?

    # Store the original values so down can restore them safely.
    internal_metadata[metadata_key] = "#{original['charset']}|#{original['collation']}"
  end

  # Revert the database default charset and collation to its original values.
  def down
    stored = internal_metadata[metadata_key]
    if stored.blank?
      raise ActiveRecord::IrreversibleMigration, 'Original charset/collation not recorded — cannot revert safely'
    end

    charset, collation = stored.split('|')
    execute "ALTER DATABASE #{connection.quote_table_name(connection.current_database)} " \
            "CHARACTER SET #{charset} COLLATE #{collation}"

    # Clean up the stored metadata value after reverting. There is no interface to remove the row.
    internal_metadata[metadata_key] = nil
  end

  private

  # Unique key scoped to this migration version to avoid collisions in ar_internal_metadata.
  def metadata_key
    "#{version}_down_database_charset_collation"
  end

  # Returns an InternalMetadata instance for reading and writing migration metadata.
  def internal_metadata
    ActiveRecord::InternalMetadata.new(self.class.connection_pool)
  end
end
