
begin
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
rescue ArgumentError
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
end

ActiveRecord::Base.configurations = true

# this schema was directly copied from 
# http://github.com/viatropos/authlogic-connect-example/blob/master/db/schema.rb
ActiveRecord::Schema.define(:version => 1) do
  
  create_table :sessions, :force => true do |t|
    t.string   :session_id, :null => false
    t.text     :data
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :tokens, :force => true do |t|
    t.integer  :user_id
    t.string   :type,       :limit => 30
    t.string   :key,        :limit => 1024
    t.string   :secret
    t.boolean  :active
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :users, :force => true do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.string   :login
    t.string   :crypted_password
    t.string   :password_salt
    t.string   :persistence_token,                :null => false
    t.integer  :login_count,       :default => 0, :null => false
    t.datetime :last_request_at
    t.datetime :last_login_at
    t.datetime :current_login_at
    t.string   :last_login_ip
    t.string   :current_login_ip
    t.string   :openid_identifier
    t.integer  :active_token_id
  end

end
