$KCODE = "U"

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
    params[:per_page] = ( params[:per_page] ? params[:per_page].to_i : 10 )
    params[:page] = ( params[:page] ? params[:page].to_i : 0 )
    Log.debug("Params: #{params.inspect}")
  end
  

  if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      MongoMapper.db.conneciton.connect_to_master if forked
    end
  end

  get '/everything/?' do
    @items = Item.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @item_count = Item.by_date.count
    @type = :everything
    haml :index
  end

  get '/' do
    @items = Post.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @item_count = Post.by_date.count
    @type = :blog
    haml :index
  end

  get '/blog/?' do
    redirect '/'
  end

  get '/blog/:stub' do |stub|
    @item = Post.first(:stub => stub)
    pass unless @item
    @type = :blog
    haml :show
  end

  get '/twitter/?' do
    @items = Tweet.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @item_count = Tweet.by_date.count
    @type = :twitter
    haml :index
  end

  get '/delicious/?' do
    @items = Bookmark.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @item_count = Bookmark.by_date.count
    @type = :delicious
    haml :index
  end

  get '/flickr/?' do
    @items = Photo.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @item_count = Photo.by_date.count
    @type = :flickr
    haml :index
  end

  get '/reader/?' do
    @items = Share.by_date.limit(params[:per_page]).skip(params[:page] * params[:per_page])
    @item_count = Share.by_date.count
    @type = :reader
    haml :index
  end

  get '/:file.css' do |file|
    content_type 'text/css'
    sass :"sass/#{file}"
  end

  private

  helpers do
    def site_link(site)
      case site
      when :blog
        '/'
      when :twitter
        'http://twitter.com/duien'
      when :delicious
        'http://delicious.com/duien'
      when :flickr
        'http://flickr.com/photos/duien'
      when :reader
        'http://www.google.com/reader/shared/price.emily'
      when :everything
        '/everything'
      end
    end

    def prev_page?
      params[:page] > 0
    end

    def prev_page
      base = "/#{@type unless @type == :blog}"
      page_params = {}
      page_params.merge!( :page => params[:page] - 1 ) unless params[:page] == 1
      page_params.merge!( :per_page => params[:per_page] ) unless params[:per_page] == 10
      "#{base}#{'?' unless page_params.empty?}#{page_params.map{ |k,v| "#{k}=#{v}" }.join('&')}"
    end

    def next_page?
      @item_count && @item_count > ( (params[:page]+1) * params[:per_page] )
    end

    def next_page
      base = "/#{@type unless @type == :blog}"
      page_params = { :page => params[:page] + 1 }
      page_params.merge!( :per_page => params[:per_page] ) unless params[:per_page] == 10
      "#{base}#{'?' unless page_params.empty?}#{page_params.map{ |k,v| "#{k}=#{v}" }.join('&')}"
    end

    def format_date(date)
      date ? date.strftime('%b %d, %Y') : "UNPUBLISHED"
    end

    def link_to(text, url, options={})
      options[:href] = url
      option_string = options.map{ |key, value| %Q[#{key}="#{value}"] }.join(' ') 
      %Q[<a #{option_string}>#{text}</a>]
    end

    def autolink(text, options={})
      text.gsub(/\b(([\w-]+:\/\/?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s“”]|\/)))/, link_to("\\1", "\\1", :class => 'link')).gsub(/( |^)@(\w+)/, "\\1" + link_to("@\\2", "http://www.twitter.com/\\2", :class => 'user'))
    end

  end

end


