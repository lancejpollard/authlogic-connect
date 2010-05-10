class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens do |t|
      t.integer :user_id
      t.string :type, :limit => 30
      t.string :key, :limit => 1024 # This has to be huge because of Yahoo's excessively large tokens
      t.string :secret
      t.boolean :active # whether or not it's associated with the account
      t.timestamps
    end
    
    add_index :tokens, :key, :unique
  end

  def self.down
    drop_table :tokens
  end
end
