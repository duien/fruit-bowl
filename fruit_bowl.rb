$KCODE = "U"
require 'logger'
require 'sinatra/base'
require 'active_support'
require 'haml'
require 'mongo_mapper'
# require 'classy'

require 'lib/config'
require 'lib/item'
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
    params[:per_page] = params[:per_page] ? params[:per_page].to_i : 10
    params[:page] = params[:page] ? params[:page].to_i : 0
  end
  

  if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      MongoMapper.db.conneciton.connect_to_master if forked
    end
  end

  get '/' do
    @items = Item.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @type = :everything
    haml :index
  end

  get '/blog/?' do
    @items = Post.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @type = :blog
    haml :index
  end

  get '/blog/:stub' do |stub|
    @item = Post.first(:stub => stub)
    pass unless @item
    @type = :blog
    haml :show
  end

  get '/twitter/?' do
    @items = Tweet.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @type = :twitter
    haml :index
  end

  get '/delicious/?' do
    @items = Bookmark.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @type = :delicious
    haml :index
  end

  get '/flickr/?' do
    @items = Photo.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @type = :flickr
    haml :index
  end

  get '/reader/?' do
    @items = Share.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @type = :reader
    haml :index
  end

  get '/:file.css' do |file|
    content_type 'text/css'
    sass :"sass/#{file}"
  end

  private

  def site_link(site)
    case site
    when :blog
      '/blog'
    when :twitter
      'http://twitter.com/duien'
    when :delicious
      'http://delicious.com/duien'
    when :flickr
      'http://flickr.com/photos/duien'
    when :reader
      'http://www.google.com/reader/shared/price.emily'
    end
  end

  def format_date(date)
    date ? date.strftime('%b %d, %Y') : "UNPUBLISHED"
  end

end


