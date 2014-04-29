require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    find_cookie(req)
  end

  def find_cookie(req)
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app'
        p "WERE HERE"
        @cookie_hash = JSON.parse(cookie.value)
      else
        p "OMG FUCK"
        @cookie_hash = {}
      end
    end
  end

  def [](key)
    @cookie_hash[key]
  end

  def []=(key, val)
    @cookie_hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    new_cookie = WEBrick::Cookie.new("_rails_lite_app", @cookie_hash.to_json)
    res.cookies << new_cookie
  end
end


# Write a helper class, Session in rails_lite/session.rb, which is passed the WEBrick::HTTPRequest on 
# initialization. It should iterate through the cookies, looking for the one named '_rails_lite_app'. 
# If this cookie has been set before, it should use JSON to deserialize the value and store this in an ivar;
#  else it should store {}.

# Provide methods #[] and #[]= that will modify the session content; in this way the Session is Hash-like. Finally, write a method store_session(response) that will make a new cookie named '_rails_lite_app', set the value to the JSON serialized content of the hash, and add this cookie to response.cookies.