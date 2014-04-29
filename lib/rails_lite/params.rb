require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = {}
    parse_www_encoded_form(req.query_string) unless req.query_string.nil?
    parse_www_encoded_form(req.body) unless req.body.nil?
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    array_of_hashes = []
    ary = URI::decode_www_form(www_encoded_form)
    ary.each do |elem|
      keys = parse_key(elem.first)
      array_of_hashes << hash_nest(keys, elem.last)
    end
    hash_merge(array_of_hashes)
    p @params
  end
  
  def hash_merge(array_of_hashes)
    array_of_hashes.each do |hash|
      deep_merge(@params, hash)
    end
  end
  
  def deep_merge(hash1, hash2)
    deep_hash = {}
    if hash1.keys.first != hash2.keys.first
      hash1[hash2.keys.first] = hash2[hash2.keys.first]
      return hash1
    else
      deep_hash[hash1.keys.first] = deep_merge(hash1[hash1.keys.first], hash2[hash2.keys.first])
    end
    return deep_hash
  end

  # we have ['user', 'address', 'street']
  def hash_nest(keys, value)
    hasher = {}
    if keys.length == 1
      hasher[keys.first] = value
      return hasher
    else
      last_key = keys.shift
      hasher[last_key] = hash_nest(keys, value)
      return hasher
    end
    
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.scan(/\w+/)
  end
end
# params = Params.new
# params.parse_www_encoded_form("user[address][street]=main")
