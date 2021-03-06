require 'bundler'
Bundler.require
Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |file| require file }
require_relative 'helpers/data_mapper'
require_relative 'helpers/warden'
require_relative 'helpers/menu_helper'
if ENV['RACK_ENV'] == 'test'
  require 'pry'
end

class SlowFood < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  register Sinatra::Warden
  helpers MenuHelpers
  set :session_secret, "supersecret"

  #Create a test User
  # if User.count == 0
  #  @user = User.create(username: "admin")
  #  @user.password = "admin"
  #  @user.save
  # end

  use Warden::Manager do |config|
    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session { |user| user.id }
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information.
    config.serialize_from_session { |id| User.get(id) }

    config.scope_defaults :default,
    # "strategies" is an array of named methods with which to
    # attempt authentication. We have to define this later.
    strategies: [:password],
    # The action is a route to send the user to when
    # warden.authenticate! returns a false answer. We'll show
    # this route below.
    action: 'auth/unauthenticated'
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env, opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  get '/' do
    erb :index
  end

  get '/dishes' do
    @dishes = Dish.all.group_by(&:category_id)
    erb :dishes
  end

  get '/contact' do
    erb :contact
  end

  get '/sitemap' do
    erb :sitemap
  end

  get '/auth/login' do
    erb :login
  end

  get '/account_creation' do
    erb :account_creation
  end

  post '/account_creation' do
    begin
      if params[:user][:password].empty?
        raise
      else
        User.create(params[:user])
        flash[:success] = 'Account created successfully'
      end
    rescue
      flash[:error] = 'Account could not be created'
    end
    redirect '/'
  end

  post '/auth/login' do
    env['warden'].authenticate!
    flash[:success] = "Successfully logged in #{current_user.username}"
    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end

  get '/auth/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash[:success] = 'Successfully logged out'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?

    # Set the error and use a fallback if the message is not defined
    flash[:error] = env['warden.options'][:message] || 'You must log in'
    redirect '/auth/login'
  end

  get '/protected' do
    env['warden'].authenticate!

    erb :protected
  end

  post '/add_to_order' do
    if current_user.nil?
      flash[:error] = 'You have to log in to be able to do that'
    else
    dish = Dish.first(id: params[:item])
      if session[:order_id]
        order = Order.get(session[:order_id])
      else
        order = Order.create(user: current_user)
        session[:order_id] = order.id
      end
      OrderItem.create(order: order, dish: dish)
      flash[:success] = "#{dish.name} has been added to your order"
      redirect '/dishes'
    end

  end
end
