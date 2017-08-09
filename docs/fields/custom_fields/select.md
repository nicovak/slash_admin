#### SELECT

```ruby
def create_params
  [
    :username,
    :email,
    :password,
    roles: {type: :select, choices: %w(superadmin admin editor), multiple: false},
  ]
end
```
