class Item
  include MongoMapper::Document

  key :body
  key :published_at, Date
  key :_type

  def self.by_date
    where(:published_at.exists => true).sort(:published_at.desc)
  end
end
