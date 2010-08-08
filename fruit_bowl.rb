$KCODE = "U"
require 'logger'
require 'sinatra/base'
require 'haml'
require 'mongo_mapper'
Dir['lib/*'].each{ |file| require file }

class FruitBowl < Sinatra::Base
  configure do
    Log = Logger.new(STDOUT)
    MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :logger => Log)
    MongoMapper.database = 'fruit-bowl'
    set :root, File.dirname(__FILE__)
    enable :static
    enable :show_exceptions if development?
  end

  before do
    content_type :html, 'charset' => 'utf-8'
  end
  

  if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      MongoMapper.db.conneciton.connect_to_master if forked
    end
  end

  get '/' do
    @items = Item.by_date
    @type = :all
    haml :index
  end

  get '/twitter/?' do
    @items = Tweet.by_date
    @type = :twitter
    haml :index
  end

  get '/:file.css' do |file|
    content_type 'text/css'
    sass :"sass/#{file}"
  end

  private

  def header_for_type(type)
    case type
    when :all
      "<span style='color: #999999'>ev</span><span style='color: #34ccff'>er</span><span style='color: #2d6abe'>yt</span><span style='color: #fc1c84'>hi</span><span style='color: #fb8417'>ng</span>"
    else
      type.to_s
    end
  end

end


