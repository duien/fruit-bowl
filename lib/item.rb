class Item
  # extend SubclassAware
  include MongoMapper::Document

  key :body
  key :published_at, Time
  key :_type

  def self.by_date
    where(:published_at.lt => Time.now,
          '$or' => [ { :_type => { '$ne' => 'Tweet' } },
                     { :_type => 'Tweet', :body => Regexp.new("^[^@]") } ]
         ).sort(:published_at.desc)

  end

  def type
    _type.to_s.underscore
  end

  def self.update_all!
    [Bookmark, Photo, Share, Tweet].each do |subclass|
    # subclasses.collect do |subclass|
      subclass.update! if subclass.respond_to? :update!
    end

  end

end
