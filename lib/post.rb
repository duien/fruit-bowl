class Post < Item

  key :title
  key :stub, :unique => true
  key :tags, Array

  before_create :set_stub

  def self.by_date
    where(:published_at.lt => Time.now).sort(:published_at.desc)
  end

  def set_stub
    self.stub = title.parameterize.to_s if stub.blank?
  end

end
