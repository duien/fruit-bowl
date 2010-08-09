require 'net/https'
require 'hpricot'

class Bookmark < Item

  key :title
  key :meta
  key :href
  key :tags

  def self.by_date
    where(:published_at.lt => Time.now).sort(:published_at.desc)
  end

  def self.update!
    begin
      if needs_update?
        last_bookmark = sort(:published_at.desc).first
        path = url[:path] + (last_bookmark ? "&fromdt=#{last_bookmark.published_at}" : '')
        response = connection.start do |http|
          request = Net::HTTP::Get.new(path)
          request.basic_auth(Config['delicious']['username'],
                             Config['delicious']['password'])
          http.request(request).body
        end

        result = Hpricot(response)
        result.search('post').each do |post|
          create(:meta => post.attributes['meta'],
                 :href => post.attributes['href'],
                 :title => post.attributes['description'],
                 :url_hash => post.attributes['hash'],
                 :tags => post.attributes['tag'].split(' '),
                 :published_at => post.attributes['time'],
                 :body => post.attributes['extended'])
        end
      end
      "Bookmarks updated"
    rescue Net::HTTPError
      "Unable to update bookmarks"
    end
  end
    
  private

  def self.needs_update?
    last_bookmark = sort(:published_at.desc).first
    return true if last_bookmark.nil?
    connection.start do |http|
      request = Net::HTTP::Get.new(url[:update_path], { 'User-Agent' => 'duien.com' })
      request.basic_auth(Config['delicious']['username'],
                         Config['delicious']['password'])
      response = http.request(request).body
      Time.parse(Hpricot(response).search('update').first.attributes['time']) > last_bookmark.published_at
    end
  end

  def self.url
    @url ||= { :base => 'api.del.icio.us', :port => 443,
               :path => '/v1/posts/all?meta=yes',
               :update_path => '/v1/posts/update' }
  end

  def self.connection
    unless @connection
      @connection = Net::HTTP.new(url[:base], url[:port])
      @connection.use_ssl = true
    end
    @connection
  end

end
