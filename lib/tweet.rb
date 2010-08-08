class Tweet < Item

  key :status_id
  key :source
  key :in_reply_to_status_id

  def self.by_date
    where(:published_at.lt => Time.now,
          :_type => 'Tweet', :body => Regexp.new("^[^@]")
         ).sort(:published_at.desc)
  end

end
