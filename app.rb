require 'sinatra'
require 'intercom'
require 'pony'

DEBUG = ENV["DEBUG"] || nil

get '/' do
  erb :index
end

get '/conversation' do
  get_conversation_details
  erb :conversation
end

post '/conversation' do
  get_conversation_details
  @email = params[:email]
  @subject = params[:subject]

  Pony.mail :to => @email, :subject => "Chat Transcript", :body => erb(:conversation), :via => :sendmail

  erb :conversation
end

def get_author_type author
  type = "admin"
  if author.class.to_s == "Intercom::Lead" then
    type = "lead"
  elsif author.class.to_s == "Intercom::User" then
    type = "user"
  end
  type
end

def is_nobody author
  author.id.nil? && get_author_type(author) == "admin"
end

def author_details author
  {type: get_author_type(author), id: author.id}
end

def get_conversation_details
  id = params[:id]
  @show_selective = params[:show_selective];
  if @show_selective == "true" then
    @show_selective = "1"
  end
  @conversation = conversation(id)
  @authors = {"user" => {}, "lead" => {}, "admin" => {}}
  @conversation.conversation_parts.each{|p| 
    tmp = author_details p.author
    @authors[tmp[:type]][tmp[:id]] = tmp
    if p.assigned_to then
      @authors["admin"][p.assigned_to.id] = 1
    end
  }
  tmp = author_details @conversation.conversation_message.author
  @authors[tmp[:type]][tmp[:id]] = 1

  @authors_details = get_all_author_details
end

def get_all_author_details
  init_intercom
  authors_details = {"user" => {}, "lead" => {}, "admin" => {}}
  @authors["lead"].each{|id, obj|
    data = @intercom.leads.find(:id => id)
    authors_details["lead"][id] = data.name || data.pseudonym || data.email || data.id
  }
  @authors["user"].each{|id, obj|
    data = @intercom.users.find(:id => id)
    authors_details["user"][id] = data.name || data.pseudonym || data.user_id || data.email || data.id
  }

  admin_ids = []
  @authors["admin"].each{|id,obj|
    admin_ids << id
  }
  data = @intercom.admins.all.select {|admin| admin_ids.include?(admin.id)}
  data.each{|admin|
    authors_details["admin"][admin.id] = admin.name || admin.email
  }
  authors_details
end

def init_intercom
  if @intercom.nil? then
    app_id = ENV["APP_ID"]
    api_key = ENV["API_KEY"]
    @intercom = Intercom::Client.new(app_id: app_id, api_key: api_key)
  end
end

def conversation (conversation_id)
  init_intercom
  begin
    @intercom.conversations.find(:id => 5841966066)

  rescue Exception => e 
    nil
  end
end

helpers do
  def author_name (author, author_list)
    type = get_author_type(author)
    id = author.id
    if is_nobody(author) then
      "Nobody"
    else
      author_list[type][id]
    end
  end
end 
