require "json"
require "colorize"

class HashDig
	# pass in unparsed string data.
  def self.dig(string_data : String?, path : String?, dig_object = JSON.parse(string_data), result=[] of JSON::Type, nodes=path.split(","), key_count = nodes.size)
    dig(parsed_data: nil, path: nil, dig_object: dig_object.as_h, result: result, nodes: nodes, key_count: key_count)
  end
  def self.dig(parsed_data : JSON::Any?, path : String?, dig_object = parsed_data.as_h, result=[] of JSON::Type, nodes=path.split(","), key_count = nodes.size)
    if (hash = dig_object.try &.as(Hash(String,JSON::Type)) )
      key = nodes.shift
      result << hash.fetch(key,nil)
    else
   		result << nil
	  end
    if result.last && nodes.any?
    	dig(parsed_data: nil, path: nil, dig_object: result.last, result: result, nodes: nodes, key_count: key_count)
  	else
	  	result.last if nodes.empty?
  	end
	end  
end

puts JSON.parse(simple_json).class
puts HashDig.dig(simple_json, "name").as(Hash(String,JSON::Type))
puts "Source: #{simple_json}".ljust(80).colorize(:dark_gray).on(:light_gray)
puts make_result "id", simple_json         # HashDig simple_json, "id"
puts make_result "name", simple_json       # HashDig simple_json, "name"
puts make_result "name,first", simple_json # HashDig simple_json, "name, first"
kids = HashDig.dig(simple_json, "children").as(Hash(String,JSON::Type))
first_kid_name, first_kid_data  = kids.first
puts format_result( "Kids Names", kids.keys.to_s,kids.keys.class.to_s)
puts format_result( "#{first_kid_name}", first_kid_data.to_s, first_kid_data.class.to_s)

def make_result(path, source : String)
  res = HashDig.dig source, path
  format_result path, res.to_s, "# #{res.class}"
  # "#{path} : ".rjust(15) + res.to_s.colorize.mode(:bright).to_s.ljust(50) + "# #{res.class}".colorize(:light_gray).to_s
end

def format_result(l,c,r)
  "#{l} : ".rjust(15) + c.colorize.mode(:bright).to_s.ljust(50) + r.colorize(:light_gray).to_s
end



def simple_json
  {
    "id": "abd0jjlkladiu2",
    "name": {
      "first": "Bob",
      "last" : "Smith" },
    "children" : {
        "Tom" : {"age" : 6, "sex" : "male" },
        "Sue" : {"age" : 4, "sex" : "female" }
      }
  }.to_json
end

