require "sinatra"
require "sinatra/activerecord"

configure (:development){set :database, "sqlite3:///blogtest.sqlite3"}
set :sessions, true

require 'bundler/setup'
require 'sinatra/base'
require 'rack-flash'

enable :sessions
use Rack::Flash, :sweep => true

require "./models"

helpers do
	def current_user
		if session[:user_id]
			current_user ||= User.find(session[:user_id])
		else
			nil
		end
	end
end

get "/" do
	if session[:user_id]
		erb :home
	else
		erb :signin
	end
end

get "/home" do
	erb :home
end

post "/sessions/new" do
	current_user = User.where(email: params[:email]).first
	if current_user && current_user.password == params[:password]
		session[:user_id] = current_user.id
		flash[:notice] = "You have been logged in sucessfully"
		redirect "/home"
	else
		flash[:alert] = "There was a problem signing you in."
		redirect "/"
	end
end

post "/users/new" do
	if params[:password] == params[:confirm_password]
		current_user = User.create(params[:user])
		flash[:notice] = "Thanks for signing up!"
		session[:user_id] = current_user.id
	else
		flash[:alert] = "There was a problem signing you up."
	end
	redirect "/"
end

get "/logout" do
	session[:user_id] = nil
	flash[:notice] = "You have been logged out sucessfully."
	redirect "/"
end

post "/posts/new" do
	Post.create(title: params[:title], content: params[:content], user_id: current_user.id)
	redirect "/profile"
end

get "/profile" do
	erb :profile
end

get "/users/:id" do
	@profile = User.find(params[:id])
	erb :user
end

get "/discover" do
	erb :users
end

get "/settings" do
	erb :settings
end

post "/settings/new" do
	if current_user.password == params[:password] && params[:new_password] == params[:confirm_password]
		current_user.update_attributes(password: params[:new_password])
		flash[:notice] = "Your password has been sucessfully changed."
	else
		flash[:alert] = "There was a problem changing your password."
	end
	redirect "/settings"
end

get "/delete" do
	current_user.destroy
	session[:user_id] = nil
	flash[:notice] = "Your account has been successfully deleted."
	redirect "/"
end

post "/edit/profile" do
	current_user.update_attributes(fname: params[:fname], lname: params[:lname])
	if current_user.profile
		current_user.profile.update_attributes(location: params[:location], website: params[:website])
	else
		Profile.create(location: params[:location], website: params[:website], user_id: current_user.id)
	end
	flash[:notice] = "Your profile has been updated successfully."
	redirect "/settings"
end

get "/unfollow/:id" do
	Relationship.find_by(follower_id: current_user.id, followed_id: params[:id]).destroy
	redirect "/home"
end

get "/follow/:id" do
	Relationship.create(follower_id: current_user.id, followed_id: params[:id])
	redirect "/profile"
end

get "/following/:id" do
	@person = User.find(params[:id])
	erb :following
end

get "/followers/:id" do
	@person = User.find(params[:id])
	erb :followers
end

get "/followingposts" do
	erb :followingposts
end

get "/deletepost/:id" do
	Post.find(params[:id]).destroy
	redirect "/profile"
end
