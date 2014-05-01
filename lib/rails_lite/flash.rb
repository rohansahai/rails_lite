require 'json'
require 'webrick'

class Flash
  def initialize(req, res)
    find_flash(req)
    @flash_now_hash = {}
    @res = res
  end
  
  def find_flash(req)
    @flash_hash = {}
    
    cookie = req.cookies.select { |cookie| cookie.name == '_rails_lite_flash' }
    p cookie
    unless cookie.first.nil?
      @flash_hash = JSON.parse(cookie.first.value)
      @flash_hash["received"] = true
    end
    
  end
  
  def [](key)
    if @flash_hash.empty?
      store_flash(@res)
      p "WE MADE IT HERE"
      #@flash_now_hash[key]
    else
      @flash_hash[key]
    end
  end
  
  def []=(key,value)
    @flash_hash[key] = value if @flash_hash["received"] == true
    @flash_now_hash[key] = value
  end
  
  def store_flash(res)
    new_cookie = WEBrick::Cookie.new("_rails_lite_flash", @flash_hash.to_json)
    res.cookies << new_cookie
  end
  
end