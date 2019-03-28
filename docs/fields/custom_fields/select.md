#### SELECT

Default `multiple` is set to `false`

```ruby
def create_params
  [
    :username,
    :email,
    :password,
    roles: { type: :select, choices: %w(superadmin admin editor), multiple: true },
  ]
end
```
