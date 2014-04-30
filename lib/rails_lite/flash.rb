require 'json'
require 'webrick'

class Flash
  def initialize(req)
    find_flash(req)
  end
  
  def find_flash(req)
    @flash_hash = {}
    @flash_hash["count"] ||= 0
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_flash'
        @flash_hash = JSON.parse(cookie.value)
        @flash_hash["count"] += 1
        p @flash_hash["count"]
      end
    end
  end
  
  def [](key)
    @flash_hash[key]
  end
  
  def []=(key,value)
    @flash_hash[key] = value
  end
  
  def store_flash(res)
    new_cookie = WEBrick::Cookie.new("_rails_lite_flash", @flash_hash.to_json)
    res.cookies << new_cookie
  end
  
end