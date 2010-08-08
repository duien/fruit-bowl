class Item
  include MongoMapper::Document

  key :body
  key :published_at, Date
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
end
