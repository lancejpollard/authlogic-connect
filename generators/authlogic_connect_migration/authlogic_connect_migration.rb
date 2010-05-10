class AuthlogicConnectMigrationGenerator < Rails::Generator::Base 
  def manifest 
    record do |m| 
      m.migration_template 'migration.rb', 'db/create_users', :migration_file_name => "create_users"
      m.migration_template 'migration.rb', 'db/create_sessions', :migration_file_name => "create_sessions"
      m.migration_template 'migration.rb', 'db/create_tokens', :migration_file_name => "create_tokens"
    end
  end
end
