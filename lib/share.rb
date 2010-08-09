class Share < Item

  key :source
  key :source_url
  key :original_url
  key :share_id, :unique => true

  def self.by_date
    where(:published_at.lt => Time.now).sort(:published_at.desc)
  end

  def self.update!
    feed_url = "http://www.google.com/reader/public/atom/user%2F03959999499646154966%2Fstate%2Fcom.google%2Fbroadcast"
    result = Hpricot(Net::HTTP.get(URI.parse(feed_url)))
    result.search('entry').each do |entry|
      share = Share.new(:title => entry.at('title').inner_text,
                        :published_at => entry.at('published').inner_text,
                        :share_id => entry.at('id').inner_text)
      share.body = entry.at('gr:annotation') &&
                   entry.at('gr:annotation').at('content') &&
                   entry.at('gr:annotation').at('content').inner_text
      share.source = entry.at('source') &&
                     entry.at('source').at('title') &&
                     entry.at('source').at('title').inner_text
      share.source_url = entry.at('source') &&
                         entry.at('source').at('link') &&
                         entry.at('source').at('link').attributes['href']
      share.original_url = entry.search('link').detect{ |l| l.attributes['rel'] == 'alternate' }.attributes['href']
      share.save 
    end
    "Shared items updated"
  end

end

