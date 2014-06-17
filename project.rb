require 'sinatra'
require 'sequel'
require 'rest_client'
require './config/db_config'
require './config/facebook_config'

DB = Sequel.connect(:adapter=>'mysql', :host=>'localhost', :database=>ConnectDB.getDatabase, :user=>ConnectDB.getUser, :password=>ConnectDB.getPass)
message_items = DB[:Message]

fb_page_url = "https://graph.facebook.com/v2.0/#{FacebookConfig.getPageID}/feed"

set :port, 9527
set :bind, '0.0.0.0'
enable :sessions
set :session_secret, 'adjfkioewjaoiriogfdkjgihjweaio'

before '/confirmMessage*' do
  session[:login_check].nil? and redirect to('/login')
end

get '/' do
	erb :index
end

post '/addMessage' do
	message_items.insert(:message => params[:message])
end

get '/login' do
	erb :login
end

post '/login' do
	if params[:id] == "admin" && params[:password] == "admin"
		session[:login_check] = true
		redirect to('/confirmMessage')
	else
		session[:login_check] = nil
		redirect to('/login')
	end
	session[:login_check]
end

get '/confirmMessage' do
	@messages = message_items.where(checked: nil).all
	erb :confirm
end

post '/confirmMessage' do
	if params[:confirm] == "true"
		message_items.where(:id => params[:id]).update(:checked=>1 )
		RestClient.post( fb_page_url, { :access_token => FacebookConfig.getToken, :message => message_items.where(:id => params[:id]).first[:message] })
	else
		message_items.where(:id => params[:id]).update(:checked=>0 )
	end
	redirect to('/confirmMessage')
end
