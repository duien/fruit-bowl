require 'flickr_fu'

class Photo < Item

  key :source_url
  key :page_url
  key :tags, Array
  key :photo_id, :unique => true

  def self.by_date
    where(:published_at.lt => Time.now).sort(:published_at.desc)
  end

  def self.update!
    user = connection.people.find_by_username('duien')
    last_photo = sort(:published_at.desc).first
    search_options = { :user_id => user.nsid }
    search_options.merge!(:min_upload_date => last_photo.published_at.to_i) if last_photo
    photos = connection.photos.search(search_options)
    photos.each do |photo|
      Photo.create(:title => photo.title,
                   :published_at => photo.uploaded_at,
                   :body => photo.description,
                   :tags => photo.tags.split(' '),
                   :page_url => photo.url_photopage,
                   :photo_id => photo.id,
                   :source_url => "http://farm#{photo.farm}.static.flickr.com/#{photo.server}/#{photo.id}_#{photo.secret}_m.jpg")
    end
    "Photos updated"
  end

  private

  def self.connection
    @connection ||= Flickr.new('config/flickr.yml')
  end

end

