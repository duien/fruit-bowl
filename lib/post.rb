class Post < Item

  key :title
  key :stub, :unique => true
  key :tags, Array

  def self.by_date
    where(:published_at.lt => Time.now).sort(:published_at.desc)
  end

end
