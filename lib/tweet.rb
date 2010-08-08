require 'net/http'

class Tweet < Item

  key :status_id, :unique => true
  key :source
  key :in_reply_to_status_id

  def self.by_date
    where(:published_at.lt => Time.now,
          :_type => 'Tweet', :body => Regexp.new("^[^@]")
         ).sort(:published_at.desc)
  end

  def self.update!
    url_base = "http://twitter.com/statuses/user_timeline.json"
    params = { 'screen_name' => 'duien',
               'include_rts' => true }
    if last_tweet =  sort(:published_at.desc).first
      params['since_id'] = last_tweet.status_id
    else
      params['count'] = 200
    end
    twitter_url = url_base + '?' + params.map{ |k,v| "#{k}=#{v}" }.join('&')
    puts twitter_url
    response = Net::HTTP.get_response(URI.parse(twitter_url))
    begin
      response.value
      tweets = JSON.parse(response.body)
      tweets.each do |tweet|
        create!( :type => 'tweet',
                 :status_id => tweet['id'], 
                 :body => tweet['text'], 
                 :published_at => Time.parse(tweet['created_at']), 
                 :source => tweet['source'],
                 :in_reply_to_status_id => tweet['in_reply_to_status_id'])
      end
      "Tweets updated"
    rescue Net::HTTPError
      "Unable to update tweets"
    end
  end

end
