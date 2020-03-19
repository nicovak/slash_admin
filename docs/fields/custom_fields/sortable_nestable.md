## Make a model sortable (sortable link in list view)

In your `routes.rb`, you have to change your routes definition, example for an `user` model:

resources :users do
  collection do
    match 'nestable', via: [:all]
  end
end

Example of migration:

```ruby
t.integer :position, null: false
```
Example in your model

```ruby
before_create :set_position

private

def set_position
  max_position = self.class.maximum(:position)
  self.position = max_position.nil? ? 1 : max_position + 1
end
```

Finaly, in your model's admin controller for only sortable:

```ruby
def nestable_config
  @is_nestable = true
  @max_depth = 1
  @position_field = :position
end
```

For nestable (multi level):

Consider using [ancestry](https://github.com/stefankroes/ancestry)

```ruby
def nestable_config
  @is_nestable = true
  @max_depth = 3
  @position_field = :position
  @acenstry_field = :ancestry
end
```

`@max_depth = 1` by default, if its one models will only be sortable. If more than `1` models will be nestable and you must provide an ancestry field.
