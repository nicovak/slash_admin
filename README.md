<p align="center">
  <img width="250" src="https://i.imgur.com/Rok5Ocf.png" />
</p>

# SlashAdmin

[![Code Climate](https://codeclimate.com/github/nicovak/slash_admin/badges/gpa.svg)](https://codeclimate.com/github/nicovak/slash_admin)
[![CircleCI](https://circleci.com/gh/nicovak/slash_admin/tree/master.svg?style=svg&circle-token=6e9ebd7fef3ebc881c75a769b0970808024a2ae9)](https://circleci.com/gh/nicovak/slash_admin/tree/master)

A modern and fully overridable admin, just the rails way.
Embeded admin user and authentication system, devise is not needed.

❤️ [Demo repository](https://github.com/nicovak/slash_admin_demo)  
🚀 [Live running](https://slashadmin.herokuapp.com/admin)

User  
`admin`

Password  
`admin@admin`

#### Motivation:
- Provide to rails the admin it deserves without DSL or obscure logic.
- Provide an easy to use and modern experience to final users.

I tried to take the best from two greats existing gem:
- [rails_admin](https://github.com/sferik/rails_admin)
- [administrate](https://github.com/thoughtbot/administrate)

Design inspired from the awesome metronic admin theme:
- [keenthemes](http://keenthemes.com/preview/metronic/)

#### Screenshots

##### Login
![Image of Login screen](https://i.imgur.com/MJerQSR.jpg)
##### Dashboard
![Image of Dashboard](https://i.imgur.com/0g3wSjw.png)
##### List
![Image of List](https://i.imgur.com/s1egSS3.png)
##### Edit / Create
![Image of Create / Edit](https://i.imgur.com/wf72pZz.png)

### Installation

Add this line to your application's Gemfile:  
```ruby
gem 'slash_admin'
```

And then execute:  
```bash
$ bundle
```

Or install it yourself as:  
```bash
$ gem install slash_admin
```

Gemfile  
```
gem 'carrierwave'
```

Then:  
```bash
rails g slash_admin:install
rails slash_admin:install:migrations
rails db:migrate
```

`config/initializers/mime_types.rb`

```ruby
Mime::Type.register "application/xls", :xls
```

```ruby
Rails.application.routes.draw do
  mount SlashAdmin::Engine => "/"
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
SlashAdmin::Admin.create!(
  username:               'admin',
  email:                  'contact@mysite.com',
  password:               'admin@admin',
  password_confirmation:  'admin@admin'
)
```

### Documentation

[Read the docs](https://github.com/nicovak/slash_admin/tree/master/docs/index.md)

## Contributing

Coming soon.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
