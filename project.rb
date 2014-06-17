require 'sinatra'
require 'sequel'
require 'rest_client'
require './config/db_config.rb'
require './config/facebook_config.rb'

DB = Sequel.connect(:adapter=>'mysql', :host=>'localhost', :database=>ConnectDB.getDatabase, :user=>ConnectDB.getUser, :password=>ConnectDB.getPass)
message_items = DB[:Message]

fb_page_url = "https://graph.facebook.com/v2.0/#{FacebookConfig.getPageID}/feed"

set :port, 9527
set :bind, '0.0.0.0'
enable :sessions
set :session_secret, 'adjfkioewjaoiriogfdkjgihjweaio'


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
		session[:login_check] = false
		redirect to('/login')
	end
	session[:login_check]
end

get '/confirmMessage' do
	if session[:login_check] == false
		redirect to('/login')
	end
	tmp = message_items.where(:checked => nil).first
	erb :confirm, :locals => { :message => tmp[:message], :id => tmp[:id] }
end

post '/confirmMessage' do
	if session[:login_check] == false
		redirect to('/login')
	end
	if params[:confirm] == "true"
		message_items.where(:id => params[:id]).update(:checked=>1 )
		RestClient.post( fb_page_url, { :access_token => FacebookConfig.getToken, :message => message_items.where(:id => params[:id]).first[:message] })
	else
		message_items.where(:id => params[:id]).update(:checked=>0 )
	end
	redirect to('/confirmMessage')
end
