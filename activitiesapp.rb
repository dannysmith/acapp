%w(sinatra dm-core dm-validations dm-timestamps dm-migrations rack-flash httparty haml yaml tzinfo net/https uri ri_cal chronic rdiscount redcloth tilt/haml).each {|r| require r}
#--------- Models

class Cadet
  include DataMapper::Resource

  property :id,         Serial    # primary serial key
  property :first_name, Text,    :required => true # cannot be null
  property :surname,    Text,    :required => true # cannot be null
  property :section,    Text,    :required => true # cannot be null
  property :code,       Text
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :allocations
  has n, :events, :through => :allocations

  def full_name
    return "#{self.surname}, #{self.first_name}"
  end

  #The future events that the cadet is attending.
  def future_events
    self.allocations.all(:attending => true).events.all(:starts_at.gt => Time.now, :order => [ :starts_at.asc ])
  end
end

class Event
  include DataMapper::Resource

  property :id,           Serial    # primary serial key
  property :title,        Text,    :required => true # cannot be null
  property :description,  Text,    :required => true # cannot be null
  property :starts_at,    DateTime,    :required => true # cannot be null
  property :finishes_at,  DateTime,    :required => true # cannot be null
  property :locked,       Boolean,     :default => false
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
      self.title.slice(0..30) + "..."
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

  belongs_to :event
  belongs_to :cadet
end




#--------- Overides & Classes

#Converts Time to dateTime
class Time
  def to_datetime
    seconds = sec + Rational(usec, 10**6)
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end
end

#Twitter Class for posting.
class Twitter
  include HTTParty
  basic_auth(ENV["TWITTER_USER"], ENV["TWITTER_PASS"])
end




class AcApp < Sinatra::Base

  enable :sessions
  #use Rack::Session::Cookie

  set :session_secret, ENV['SESSION_KEY']
  use Rack::Flash
  use Rack::MethodOverride ##<-- Required for put delete
  #--------- Configuration Block

  configure(:development) do
    require 'better_errors'
    require 'pry'
    require './development-envs'

    use BetterErrors::Middleware
    BetterErrors.application_root = File.expand_path File.dirname(__FILE__)
    BetterErrors.editor = :sublime
  end

  configure do
    #Load passwords from config file
    if File.exist?("./config.yml")
      config = YAML.load_file("./config.yml")
      config.each do |k, v|
        ENV[k] = v.to_s
      end
    end

    set :timezone, TZInfo::Timezone.get(ENV['TIMEZONE'])

    # Checks whether we're on heroku or local. Loads correct DB.
    DataMapper.setup(:default, (ENV["DATABASE_URL"] || "postgres://localhost/acapp"))
    DataMapper.auto_upgrade!
  end

  #--------- Helper Methods

  helpers do

    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def unauthorized!(realm="localhost")
      response['WWW-Authenticate'] = %(Basic realm="#{realm}")
      throw :halt, [ 401, 'Authorization Required' ]
    end

    def bad_request!
      throw :halt, [ 400, 'Bad Request' ]
    end

    def authorized?
      request.env['REMOTE_USER']
    end

    def authorize(username, password)
      if username == "226" && password == ENV["ADMIN_PASS"]
        session['admin'] = true
        return true
      end
      false
    end

    def protected!
      return if authorized?
      unauthorized! unless auth.provided?
      bad_request! unless auth.basic?
      unauthorized! unless authorize(*auth.credentials)
      request.env['REMOTE_USER'] = auth.username
    end

    def admin?
      session['admin']
    end

    def format_time_range(start_time, end_time)
      output = to_timezone(start_time).strftime('%H%Mhrs')
      output << ", #{to_timezone(start_time).strftime('%d %b %Y')}" if start_time.day != end_time.day
      output << " &mdash; #{to_timezone(end_time).strftime('%H%Mhrs')}" unless end_time.nil?
      if start_time.day == end_time.day
        output << ", #{to_timezone(start_time).strftime('%d %b %Y')}"
      else
        output << ", #{to_timezone(end_time).strftime('%d %b %Y')}"
      end
    end

    def to_timezone(datetime)
      settings.timezone.utc_to_local(datetime.new_offset(0))
    end

    def to_timezone_date(datetime)
      current = to_timezone(datetime)
      Date.new(current.year, current.month, current.day)
    end

    def gcal_url(cal)
      "https://calendar.google.com/calendar/ical/#{ENV[cal]}/public/basic.ics"
    end

    def gcal_feed_url(cal)
      "https://www.google.com/calendar/feeds/#{ENV[cal]}/public/basic"
    end

    alias_method :h, :escape_html
  end

  #--------- Page Handlers - General

  # Home
  get '/' do
    redirect '/events'
  end

  #--------- Page Handlers - Cadets

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
    @require_response = Event.all(:starts_at.gt => Time.now, :order => [ :starts_at.asc ]) - @cadet.events

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


  #--------- Page Handlers - Events & Allocations

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

      #Post message to Twitter
      url = ENV["SITE_URL"]
      url = "#{url}/events/#{@event.id}"
      message = "#{@event.truncated_title} #{url}"
      twt = Twitter.post("http://twitter.com/statuses/update.json", :query => {:status => message})
      twitter_flash = twt["error"]
      twitter_flash ? twitter_flash = "Twitter Error: #{twitter_flash}" : twitter_flash = "Message posted to twitter."
      flash[:message] = "Event Created! #{twitter_flash}"
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
    if params[:code] == Cadet.get(params[:cadet_id]).code || admin? #If the access code is correct.

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

  #Update Event (Locking Event Hack)
  put '/events/:id/togglelock' do
    protected!
    @event = Event.get(params[:id])
    @event.locked = !@event.locked?
    if @event.save
      flash[:message] = "Lock setting changed - lock set to: #{@event.locked}"
      redirect "/events/#{@event.id}"
    else
      flash[:message] = "Sorry, the record couldn't be updated."
      redirect '/events'
    end
  end



  ########## Other Pages ##########

  get "/programme" do
    https = Net::HTTP.new('www.google.com', 443)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    ical_string = https.get(gcal_url('GCAL1')).body
    components = RiCal.parse_string ical_string
    @calendar = components.first
    @calendar_name = @calendar.x_properties['X-WR-CALNAME'].first.value
    @today = to_timezone_date(DateTime.now)
    occurrences = @calendar.events.map do |e|
      e.occurrences(:starting => @today, :before => @today + ENV['LOOKAHEAD1'].to_i)
    end
    @events = occurrences.flatten.sort { |a,b| a.start_time <=> b.start_time }

    haml :'gcal/programme', :layout => false
  end




  get "/listing" do
    https = Net::HTTP.new('www.google.com', 443)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    ical_string = https.get(gcal_url('GCAL2')).body
    components = RiCal.parse_string ical_string
    @calendar = components.first
    @calendar_name = @calendar.x_properties['X-WR-CALNAME'].first.value
    @today = to_timezone_date(DateTime.now)
    occurrences = @calendar.events.map do |e|
      e.occurrences(:starting => @today, :before => @today + ENV['LOOKAHEAD2'].to_i)
    end
    @events = occurrences.flatten.sort { |a,b| a.start_time <=> b.start_time }

    haml :'gcal/eventlisting', :layout => false
  end

  get "/hello" do
    haml :hello, :layout => false
  end

end
