## HashDig

It's a little tricky getting through deeply-nested JSON data with Crystal, a consequence of stronger types.  Since each value can be any of `JSON::Type`,  you can't traverse deeper into the object until you've cast  it to a Hash.  But this gets ugly.

This class attempts to make it easier dig deeply into the hash by passing a string path.  The `hash_dig.cr`source file has an example of this, which is explained here.

Take a JSON object that gets sent back to the server:

```json
  {
    "id": "abd0jjlkladiu2",
    "name": {
      "first": "Bob",
      "last" : "Smith" },
    "children" : {
        "Tom" : {"age" : 6, "sex" : "male" },
        "Sue" : {"age" : 4, "sex" : "female" } }
  }
```

That's going to come into the server as a string:

```ruby
string_data = "{\"id\":\"abd0jjlkladiu2\",\"name\":{\"first\":\"Bob\",\"last\":\"Smith\"},\"children\":{\"Tom\":{\"age\":6,\"sex\":\"male\"},\"Sue\":{\"age\":4,\"sex\":\"female\"}}}\"
```

The first step is to parse it

```ruby
JSON.parse string_data    # JSON::Any
```

But now you're faced with parsing every step along the way; it even has to be cast into a Hash before you can accessing the first key/value pairs.  Ultimately, the `string_data` received is just a delivery vehicle for individual bits of data meaningful to the application.   So here's what `HashDig` does:  it recursively traverses the provided path, and if it's able to get all the way to the end of the path, it returns the value it finds.  If it can't traverse the entire path, it returns `nil`.  

First, some simple examples, on the first level of the example JSON:

```ruby
name = HashDig simple_json, "name"    # {"first" => "Bob", "last" => "Smith"}
id   = HashDig simple_json, "id"      # "abd0jjlkladiu2"
```

How about getting the first name from the data?

```ruby
first_name = HashDig simple_json, "name,first"  # "Bob"
```

It's important to note at this point that the _compile time_ type of `name`, `id`, and `first_name` are still `JSON::Type`; you will need to do a final conversion, so maybe it looks more like this:

```ruby
name=HashDig(simple_json,"name").as(Hash(String,JSON::Type))  # {"first" => "Bob", "last" => "Smith"}
id=HashDig(simple_json, "id").as(String)        		 # "abd0jjlkladiu2"
first_name=HashDig(simple_json, "name,first").as(String) # "Bob"
```



### Future Improvements

It having to do a final cast at the end is a bit of a pain.  In the name example, the resulting hash is `Hash(String,String)` but it can't be case directly with `#as()` into this format.  

Another area not addressed is arrays.  The ability to traverse arrays and other objects by including a means of passing the index in the path would be helpful: `HashDig.dig simple_json, "children,2,age"`would return the age of the second child.