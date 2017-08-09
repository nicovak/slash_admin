## Google map
Strategy: use a serialized field to store all datas returned by Google.

### Migration example:
```ruby
def change
  add_column :users, :google_map, :text
end
```

#### In your model:
```ruby
class User < ActiveRecord::Base
  serialize :google_map, JSON
end
```

Needed configuration for field:

```ruby
def create_params
  [
    {
      my_field: {
      type: :google_map,
      default_zoom_level: 13,
      google_api_key: 'API KEY FROM GOOGLE',
      default_latitude: '48.8534',
      default_longitude: '2.3488'
      }
    }
  ]
end
```

Example of JSON stored values, everything is built dynamically.

```javascript
{
  "location":{
      "latitude":45.5016889,
      "longitude":-73.56725599999999
   },
   "formatted_address":"Montréal, QC, Canada",
   "locality":"Montréal",
   "political":"Canada",
   "administrative_area_level_3":"Pointe-Calumet",
   "administrative_area_level_2":"Communauté-Urbaine-de-Montréal",
   "administrative_area_level_1":"Québec",
   "country":"Canada"
}
```

Example of usage in a view

```
<%= u.google_map['location']['latitude'] %>
<%= u.google_map['country'] %>
<%= u.google_map['formatted_address'] %>
```
