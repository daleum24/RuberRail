require 'uri'

class Params
  def initialize(req, route_params = {})
    req_query = req.query_string
    req_body  = req.body
    puts "This is req: #{req}"
    puts "This is req query: #{req_query}"
    puts "This is req body: #{req_body}"
    if req_query
      puts "IN REQ QUERY"
      @params = parse_www_encoded_form(req_query)
    elsif req_body
      puts "IN REQ BODY"
      @params = parse_www_encoded_form(req_body)
    end

  end

  def [](key)
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
