require 'sequel'
require '../config/db_config.rb'

DB = Sequel.connect(:adapter=>'mysql', :host=>'localhost', :database=>ConnectDB.getDatabase, :user=>ConnectDB.getUser, :password=>ConnectDB.getPass)


DB.create_table(:Message) do
	primary_key :id, :type=>Bignum
	String :message, :text=>true
	FalseClass :checked
end
