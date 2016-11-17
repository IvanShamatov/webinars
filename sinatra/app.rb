class App < Sinatra::Base
  get '/' do 
    erb :index
  end

  post '/' do 
    res = PostUrl.call(params[:original_url])
    @shortned_url = res.shortned_url
    erb :index
  end

  get '/:url_code' do 
    res = GetUrl.call(params[:url_code])
    redirect to(res.original_url)
  end

end

class GetUrl
  attr_accessor :original_url

  def self.call(key)
    new(key)
  end

  def initialize(key)
    @key = key
    @original_url = client.get(@key)
  end

  def client
    @client ||= Redis.new
  end 
end


class PostUrl
  WEEK = 7*24*60*60

  attr_accessor :original_url, :shortned_url

  def self.call(url)
    new(url)
  end

  def initialize(original_url)
    @original_url = original_url
    generate_short_url
    save
  end

  def client
    @client ||= Redis.new
  end 

  def save
    client.set(shortned_url, original_url)
    client.expire(shortned_url, WEEK)
  end

  def generate_short_url
    loop do
      pre_url = (0...6).map { (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).sample }.join
      if client.get(pre_url).nil?
        @shortned_url = pre_url
        break
      end
    end
  end

end
