require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'mustache'
require 'rack-flash'
require 'chronic'
require 'httparty'
require 'shorturl'
require 'haml'

enable :sessions
use Rack::Flash

#Set the Password for HTTP Auth
PASSWORD = 'Telegraph'
SITE_URL = "http://localhost:4567" #don't include trailing slash
TWITTER_USERNAME = 'bactester'
TWITTER_PASS = 'telegraph'

#Additional to_dateTime method
class Time
  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end
end

#Twitter Class
class Twitter
  include HTTParty
  base_uri "twitter.com"
  basic_auth TWITTER_USERNAME, TWITTER_PASS
end

#TinyURL Class for shortening URLs
#class TinyURL
#  include HTTParty
#  
#  def self.shorten(url)
#    get("http://tinyurl.com/api-create.php?url=#{url}")
#  end
#  
#end

class Cadet
  include DataMapper::Resource

  property :id,         Serial    # primary serial key
  property :first_name, Text,    :required => true # cannot be null
  property :surname,    Text,    :required => true # cannot be null
  property :section,    Text,    :required => true # cannot be null
  property :code,       Text
  property :created_at, DateTime
  property :updated_at, DateTime

  # validates_present :body

  has n, :allocations
  has n, :events, :through => :allocations

  def full_name
    return "#{self.surname}, #{self.first_name}"
  end
  
  def future_events
    self.allocations.all(:attending => true).cadets.events.all(:starts_at.gt => Time.now, :order => [ :starts_at.asc ])
  end
end

class Event
  include DataMapper::Resource

  property :id,           Serial    # primary serial key
  property :title,        Text,    :required => true # cannot be null
  property :description,  Text,    :required => true # cannot be null
  property :starts_at,    DateTime,    :required => true # cannot be null
  property :finishes_at,  DateTime,    :required => true # cannot be null
  property :created_at,   DateTime
  property :updated_at,   DateTime

  
  has n, :allocations
  has n, :cadets, :through => :allocations
  
  def attendees
    self.allocations.all(:attending => true).cadets
  end
  
  def absentees
    self.allocations.all(:attending => false).cadets
  end
  
  def start_date
    self.starts_at.strftime('%a %d %b %Y')
  end
  
  def finish_date
    self.finishes_at.strftime('%a %d %b %Y')
  end
  
  def start_time
    self.starts_at.strftime('%H:%M')
  end
  
  def finish_time
    self.finishes_at.strftime('%H:%M')
  end
  
  def start_date_for_edit
    "#{self.starts_at.strftime('%d %b %Y')} at #{start_time}"
  end
  
  def finish_date_for_edit
    "#{self.finishes_at.strftime('%d %b %Y')} at #{finish_time}"
  end
  
  def date
    if self.start_date == self.finish_date
      self.start_date
    else
      "#{self.start_date} - #{self.finish_date}"
    end
  end
  
  def truncated_title
    if self.title.length > 30
      self.title.slice(0..30) + "…"
    else
      self.title
    end
  end
end

class Allocation
  include DataMapper::Resource

  property :cadet_id,   Integer,  :required => true, :key => true
  property :event_id,   Integer,  :required => true, :key => true
  property :attending,  Boolean,  :default  => false
  property :responded,  Boolean,  :default  => false
  property :created_at, DateTime
  property :updated_at, DateTime

  # validates_present :body

  belongs_to :event
  belongs_to :cadet
end

configure do
  # Heroku has some valuable information in the environment variables.
  # DATABASE_URL is a complete URL for the Postgres database that Heroku
  # provides for you, something like: postgres://user:password@host/db, which
  # is what DM wants. This is also a convenient check wether we're in production
  # / not.
  DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/activitiesapp.sqlite3"))
  DataMapper.auto_upgrade!
end

#--------------Helper Methods--------------------------------------------
helpers do

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="226 Events Mgmt Staff")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['226', PASSWORD]
  end

end
#-------------Generic Page handlers---------------------------------------------

# Home
get '/' do
  redirect '/events'
end






#-------------------- Cadet Page Handlers ----------------------------
# List Cadets
get '/cadets/?' do
  @cadets = Cadet.all(:order => [ :surname.asc ])
  haml :'cadets/list'
end

#List Cadets with Access codes
get '/cadets/codes/?' do
  protected!
  @cadets = Cadet.all
  haml :'cadets/codes'
end

#Show form for a new cadet.
get '/cadets/new/?' do
  protected!
  haml :'cadets/new'
end

#Create cadet
post '/cadets' do
  protected!
  @cadet = Cadet.new(params)
  @cadet.code = "#{rand(9)}#{rand(9)}#{rand(9)}"
  if @cadet.save
    flash[:message] = "Created cadet. Their access code is #{@cadet.code}"
    redirect "/cadets/#{@cadet.id}"
  else
    flash[:message] = "The record couldn't be saved."
    redirect '/cadets'
  end
end

#Delete Cadet
delete '/cadets/:id' do
  protected!
  @cadet = Cadet.get(params[:id])
  if @cadet.destroy
    flash[:message] = "Deleted."
    redirect '/cadets'
  else
    flash[:message] = "The cadet with id #{params[:id]} couldn't be deleted."
    redirect "/cadets/#{params[:id]}"
  end
end

#View cadet
get '/cadets/:id/?' do
  @cadet = Cadet.get(params[:id])
  @require_response = Event.all - @cadet.events
  
  if @cadet
    haml :'cadets/show'
  else
    flash[:message] = "Couldn't find cadet with id #{params[:id]}"
    redirect '/cadets'
  end
end

#Show form for a current cadet.
get '/cadets/:id/edit/?' do
  protected!
  @cadet = Cadet.get(params[:id])
  haml :'cadets/edit'
end

#Update cadet
put '/cadets/:id' do
  protected!
  @cadet = Cadet.get(params[:id])
  @cadet.first_name = params[:first_name]
  @cadet.surname = params[:surname]
  @cadet.section = params[:section]
  @cadet.code = params[:code]
  if @cadet.save
    flash[:message] = "Record Updated."
    redirect "/cadets/#{@cadet.id}"
  else
    flash[:message] = "Sorry, the record couldn't be updated."
    redirect '/cadets'
  end
end


#----------- Events Handlers ----------------------
#List Events
get '/events/?' do
  @future_events = Event.all(:starts_at.gt => Time.now, :order => [ :starts_at.asc ])
  haml :'events/list'
end

#Show Events form
get '/events/new/?' do
  protected!
  haml :'events/new'
end

get '/events/past/?' do
  @past_events = Event.all(:starts_at.lt => Time.now, :order => [ :starts_at.desc ])
  haml :'events/past'
end

#Create Event
post '/events' do
  protected!
  @event = Event.new
  @event.title = params[:title]
  @event.description = params[:description]
  @event.starts_at = Chronic.parse(params[:starts_at]).to_datetime
  @event.finishes_at = Chronic.parse(params[:finishes_at]).to_datetime
  if @event.save
    flash[:message] = "Event Created & message sent to Twitter"
    #Post message to Twitter
    url = "#{SITE_URL}/events/#{@event.id}"
    message = "New forthcoming activity: #{@event.truncated_title} #{ShortURL.shorten(url, :tinyurl)}"
    tweet = Twitter.post("/statuses/update.json", :query => {:status => message})
    redirect "/events/#{@event.id}"
  else
    flash[:message] = "The event couldn't be saved."
    redirect '/events'
  end
end

#Delete Event
delete '/events/:id' do
  protected!
  @event = Event.get(params[:id])
  if @event.destroy
    flash[:message] = "Deleted"
    redirect '/events'
  else
    flash[:message] = "The event with id #{params[:id]} couldn't be deleted."
    redirect "/events/#{params[:id]}"
  end
end

#Show Event
get '/events/:id/?' do
  @cadets = Cadet.all(:order => [ :surname.asc ])
  @event = Event.get(params[:id])
  @attending_cadets = @event.attendees.all(:order => [ :surname.asc ])
  @absent_cadets = @event.absentees.all(:order => [ :surname.asc ])
  @cadets_not_responded = @cadets - @event.cadets
  
   if @event
     haml :'events/show'
   else
     flash[:message] = "Couldn't find an event with id #{params[:id]}"
     redirect '/events'
   end
end



#Show Event Edit Form
get '/events/:id/edit/?' do
  protected!
  @event = Event.get(params[:id])
  haml :'events/edit'
end



#Create or update an allocation
post '/events/:id/allocate/?' do
  if params[:code] == Cadet.get(params[:cadet_id]).code #If the access code is correct.
    
    @allocation = Allocation.get(params[:cadet_id], params[:id]) #Get the allocation record if it exists - this is an update.
    @allocation ||= Allocation.new(:event_id => params[:id], :cadet_id => params[:cadet_id], :responded => true) #Or create a new record.
    @allocation.attending = params[:attending] #Set attendance
    if @allocation.save
      flash[:message] = "Saved"
      redirect "/events/#{params[:id]}"
    else
      flash[:message] = "Sorry, something went wrong with the system."
      redirect "/events/#{params[:id]}"
    end
  
  else #If the access code was wrong.
    flash[:message] = "Your access code was wrong. No record has been made. If you can't remember your code, ask a member of staff nicely for it."
    redirect "/events/#{params[:id]}"
  end
  
end
 
 
 
 
 
#Return whether a cadet is attending an event?
get '/events/:event_id/check/:cadet_id' do
  @allocation = Allocation.get(params[:cadet_id], params[:event_id])
  
  if not @allocation.nil?
    @allocation.attending? ? "true" : "false"
  else
    "nil"
  end
end






#Display those attending
get '/events/:id/attending' do
  @cadets = Event.get(params[:id]).attendees
  haml :'events/listing', :layout => false
end

#Display those NOT attending
get '/events/:id/absent' do
  @cadets = Event.get(params[:id]).absentees
  haml :'events/listing', :layout => false
end

#Display those not responded
get '/events/:id/noresponse' do
  @cadets = Cadet.all - Event.get(params[:id]).cadets
  haml :'events/listing', :layout => false
end







#Update Event
put '/events/:id' do
  protected!
  @event = Event.get(params[:id])
  @event.title = params[:title]
  @event.description = params[:description]
  @event.starts_at = Chronic.parse(params[:starts_at]).to_datetime
  @event.finishes_at = Chronic.parse(params[:finishes_at]).to_datetime
  if @event.save
    flash[:message] = "Record Updated."
    redirect "/events/#{@event.id}"
  else
    flash[:message] = "Sorry, the record couldn't be updated."
    redirect '/events'
  end
end

