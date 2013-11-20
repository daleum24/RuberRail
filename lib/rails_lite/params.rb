require 'uri'

class Params
  def initialize(req, route_params = {})
    if route_params
      @params = route_params
    else
      @params = {}
    end

    puts "ROUTE PARAMS: #{@params}"
    req_query = req.query_string
    req_body  = req.body

    puts "REQ: #{req}"
    puts "REQ QUERY: #{req_query}"
    puts "REQ BODY: #{req_body}"

    if req_query
      @params = @params.merge(parse_www_encoded_form(req_query))
      puts "ROUTE PARAMS + QUERY: #{@params}"
    elsif req_body
      @params = @params.merge(parse_www_encoded_form(req_body))
      puts "ROUTE PARAMS + BODY: #{@params}"
    end

  end

  def [](key)
    @params[key]
  end

  def to_s
    # @params.to_json
    "#{@params}"
  end

  private
  def parse_www_encoded_form(www_encoded_form)

    output_hash = {}

    params_array = URI::decode_www_form(www_encoded_form)

    params_array.each do |el|
      output_hash[el[0]] = el[1]
    end

    final_arr = []

    output_hash.each do |key, value|
      all_keys = parse_key(key).reverse

      first_key = all_keys.shift
      current_hash = { first_key => value }

      until all_keys.empty?
        current_hash = { all_keys.shift => current_hash }
      end
      final_arr << current_hash
    end

    value_hash = {}

    final_arr.each do |hash|
      value_hash.merge!(hash.values.first)
    end

    params_hash = { final_arr.first.keys.first => value_hash }

  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
