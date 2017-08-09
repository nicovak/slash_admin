### Installation
Add this line to your application's Gemfile:

```ruby
gem 'relax_admin'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install relax_admin
```

Gemfile
```
gem 'carrierwave'
```

Then:
```bash
rails g relax_admin:install
rails relax_admin:install:migrations
rails db:migrate
```

`config/initializers/mime_types.rb`
```ruby
Mime::Type.register "application/xls", :xls
```

```ruby
Rails.application.routes.draw do
  mount RelaxAdmin::Engine => "/"
end
```

Mounted as '/' but prefixed in the gem and in routes definition of models admin. See above.

### Important

If you are using [friendly_id](https://github.com/norman/friendly_id) gem, you have to add `routes: :default` like so:

```ruby
friendly_id :title, use: :history, routes: :default
```

Example of create admin in `seed.rb` in your app:

```ruby
RelaxAdmin::Admin.create!(
  username:               'admin',
  email:                  'contact@mysite.com',
  password:               'admin@admin',
  password_confirmation:  'admin@admin'
)
```
