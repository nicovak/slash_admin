# [W.I.P] Relax Admin

A modern and overridable admin, just the rails way.
Embeded admin user and authentication system, devise is not needed.

#### Motivation:
- Provide to rails the admin it deserves without DSL or obscure logic.
- Provide an easy to use and modern experience to final users.
- Improve my personal skill and try rails engine

I tried to take the best from two greats existing gem:
- [rails_admin](https://github.com/sferik/rails_admin)
- [administrate](https://github.com/thoughtbot/administrate)

Design inspired from the awesome metronic admin theme:
- [keenthemes](http://keenthemes.com/preview/metronic/)

#### Screenshots

![Image of Login screen](http://i.imgur.com/HFQ9hfw.jpg)
![Image of List](http://i.imgur.com/p34HUU5.png)
![Image of Create / Edit](http://i.imgur.com/TzOx3i8.png)

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

### Techs

- Rails 5
- Bootstrap 4
- Ruby 2.4.0

### Dashboard
- [X] Charts
- [X] Easy widget system
- [ ] I18n
- [ ] Global search
- [X] Integration of roles and permission with [cancancan](https://github.com/CanCanCommunity/cancancan)

### Create / Edit
- [X] Default params for create
- [ ] Handling form and helpers

### List
- [X] Default export of model (excel and csv)
- [X] Filter system + search based on data type
- [X] Batch action
- [X] Pagination
- [ ] Handle `has_one` and `belongs_to`
- [ ] Sortable and nested list
- [ ] Better handling of field type

### Miscellaneous

- [ ] Tests
- [ ] Heroku Demo
- [ ] Wiki
- [ ] Docs

### Generators (for overriding)

- [X] Install & Initial setup
- [X] Controllers
- [X] Override `sessions_controller`
- [X] Override `admin` model
- [ ] Views
- [ ] Custom fields
- [ ] Custom JS & CSS file

### Fields form

- [X] `belongs_to`
- [X] `has_many`
- [X] nested `has_many`
- [ ] `has_one`
- [ ] nested `has_one`
- [X] `boolean`
- [X] `carrierwave`
- [X] `date`, `datetime`
- [X] `string`
- [X] `text`
- [X] `integer`
- [X] `number`

### Custom fields form

You can create your own custom field within `app/views/relax_admin/custom_fields/_{type (see below)}.html.erb`
eg: `roles: {type: :select, choices: %w(superadmin admin editor), multiple: false}`

- [X] Color
- [X] WYSIWYG
- [X] Select
- [ ] Google Map
- [X] nested `belongs_to`
- [X] Tags (string delimited with ';', ',', '.', ' ')

Use case:

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

#### COLOR

```ruby
def create_params
  [
    color: {type: :color},
  ]
end
```

#### TAGS

```ruby
def create_params
  [
    tags: {type: :tags},
  ]
end
```

#### WYSIWYG (using froala)

Add in your route.rb

```ruby
namespace :relax_admin, path: '/admin' do
    # FROALA (WYSIWYG)
    post   'froala_upload' => 'froala#upload'
    post   'froala_manage' => 'froala#manage'
    delete 'froala_delete' => 'froala#delete'

    ...

    scope module: 'models' do
      ...
    end
```

Create a froala dedicated controller (for image uploads and file uploads)

In `app/controllers/relax_admin/froala_controller.rb`

```ruby
# frozen_string_literal: true
module RelaxAdmin
  class FroalaController < RelaxAdmin::BaseController
    def upload
      uploader = FroalaUploader.new(params[:type].pluralize)
      uploader.store!(params[:file])

      respond_to do |format|
        format.json { render json: {status: 'OK', link: uploader.url} }
      end
    end

    def delete
      filename = params[:src].split('/').last
      file_path = "uploads/froala/images/#{filename}"
      path = "#{Rails.root}/public/#{file_path}"

      FileUtils.rm(path)

      respond_to do |format|
        format.json { render json: {status: 'OK'} }
      end
    end

    def manage
      files = []

      file_path = "uploads/froala/images"
      real_file_path = "#{request.headers['HTTP_ORIGIN']}/uploads/froala/images/"
      path = "#{Rails.root}/public/#{file_path}"

      if File.directory?(path)
        Dir.foreach(path) do |item|
          next if (item == '.') || (item == '..')
          object = ObjectImage.new
          object.url = real_file_path + item
          object.thumb = real_file_path + item
          object.tag = params[:model]

          files << object
        end
      end

      respond_to do |format|
        format.json { render json: files }
      end
    end

    class ObjectImage
      attr_accessor :url, :thumb, :tag
    end
  end
end
```

In `app/uploaders/froala_uploader.rb`

```ruby
class FroalaUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/froala/#{mounted_as}"
  end
end
```

Finally, in your `app/assets/javascripts/relax_admin/custom.js`

Don't forget `//= stub relax_admin/custom` at the end of your `app/assets/javascripts/application.js`

```javascript
$(document).on('turbolinks:load', initCustom);

function initCustom() {
  $('.froala-editor').froalaEditor({
    height: 250,
    toolbarButtons: ['fullscreen', 'bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript', '|', 'fontFamily', 'fontSize', 'color', 'inlineStyle', 'paragraphStyle', '|', 'paragraphFormat', 'align', 'formatOL', 'formatUL', 'outdent', 'indent', 'quote', '-', 'insertLink', 'insertImage', 'insertVideo', 'insertFile', 'insertTable', '|', 'emoticons', 'specialCharacters', 'insertHR', 'selectAll', 'clearFormatting', '|', 'print', 'help', 'html', '|', 'undo', 'redo'],
    pluginsEnabled: null,
    imageUploadURL: '/relax_admin/froala_upload',
    imageUploadParam: 'file',
    imageUploadParams: {
      type: 'image',
    },
    fileUploadURL: '/admin/froala_upload',
    fileUploadParam: 'file',
    fileUploadParams: {
      type: 'file',
    },
    imageManagerLoadMethod: 'POST',
    imageManagerLoadURL: '/admin/froala_manage',
    imageManagerLoadParams: {
      format: 'json',
    },
    imageManagerDeleteMethod: 'DELETE',
    imageManagerDeleteURL: '/admin/froala_delete',
    imageManagerDeleteParams: {
      format: 'json',
    },
  });
}
```

Icons available:
- http://fontawesome.io/ (eg: `fa fa-home`)
- http://simplelineicons.com/ (eg: `icon-home`)

Exemple of process to add a new 'page' model:

```ruby
module RelaxAdmin
  class MenuHelper
    def menu_entries
      [
        {
          title: 'Dashboard',
          path: relax_admin.dashboard_path,
          icon: 'icon-home',
        },
        {
          title: 'Content',
          icon: 'icon-crop',
          sub_menu: [
            {model: Page, icon: 'icon-book-open'},
          ],
        }
      ]
    end
  end
end
```

Custom action: (eg a menu builder section) without a linked existing model

```ruby
...
sub_menu: [
  {path: relax_admin_menu_builder_path, icon: 'icon-organization', title: 'Menu'},
...
```

Route in `app/config/routes.rb`

```ruby
...
get 'menu' => 'menus#builder', as: 'menu_builder'
post 'menu' => 'menus#builder', as: 'menu_builder_action'
...
```

Controller in `app/controllers/relax_admin/models/menus_controller.rb`

```ruby
module RelaxAdmin
  module Models
    class MenusController < RelaxAdmin::BaseController
      def builder
      end

      def handle_default
        super
        @title = 'My Menu Builder'
      end

      def index; end
    end
  end
end
```

Finally create your view in `app/views/relax_admin/models/builder.html.erb`

```erb
<% page_title(@title) %>
<% page_sub_title(@sub_title) %>

My content
```

## Routes

No role or acccess security right now.
You can define `except` and `only` on ressources

```ruby
namespace :relax_admin, path: 'admin' do
  scope module: 'models' do
    resources :pages
  end
end
```

## Sample controller (mandatory), in `app/controllers/relax_admin/models` folder

For references see: app/controllers/admin/models_controller.rb and app/controllers/admin/base_controller.rb
Everything is overridable for each controller and each model (params, views, field, etc)

**def list_params method is mandatory**

You can generate an admin controller (e.g for page model):

```bash
rails g relax_admin:controllers pages
```

```ruby
module RelaxAdmin
  module Models
    class PagesController < RelaxAdmin::ModelsController
      def list_params
        [
          image: {type: 'image'}
          :title,
        ]
      end

      def export_params
        [
          :title,
        ]
      end
    end
  end
end
```

### Available and most commons usage

In controller:

```ruby
def handle_default
  @sub_title = nil
  @per = 10
  @page = 1
  @per_values = [10, 20, 50, 100, 150]
  @order_field = :id
  @order = 'DESC'
end
```

Eg: I wanna change the @per values for my controller:

```ruby
  def handle_default
    super # call super method to keep other instance variables
    @per = 20
  end
```

## Handle permission with [cancancan](https://github.com/CanCanCommunity/cancancan)

Just run `rails g relax_admin:permissions` and edit the generated file according [docs](https://github.com/CanCanCommunity/cancancan/wiki/defining-abilities)

## Override admin model or sessions_controller

You can override the default logic for authentication, and you can modify the default admin model.

```bash
rails g relax_admin:override_session
rails g relax_admin:override_admin
```

## Helpers

```erb
<% page_title('Title') %>
<% page_sub_title('Sub') %>
```

## Widgets
```erb
<%= statistic_progress_tile(title: 'My title', number: 18000, icon: 'fa fa-globe', percent: 80, progress_label: 'progression', status: 'success') %>
```

## Make a model sortable (sortable link in list view)

In your `routes.rb`, you have to change your routes definition, example for an `user` model:

resources :users do
  collection do
    match 'nestable', via: [:all]
  end
end

Example of migration:

```ruby
...
t.integer :position, null: false
...
```
Example in your model

```ruby
...
before_create :set_position

private

def set_position
  max_position = self.class.maximum(:position)
  self.position = max_position.nil? ? 1 : max_position + 1
end
```

Finaly, in your model's admin controller for only sortable:

```ruby
...
def nestable_config
  @is_nestable = true
  @max_depth = 1
  @position_field = :position
end
...
```

For nestable (multi level):

Consider using [ancestry](https://github.com/stefankroes/ancestry)

```ruby
...
def nestable_config
  @is_nestable = true
  @max_depth = 3
  @position_field = :position
  @acenstry_field = :ancestry
end
...
```

`@max_depth = 1` by default, if its one models will only be sortable. If more than `1` models will be nestable and you must provide an ancestry field.

## Custom JS & CSS

### For JS

Create a file here `app/assets/javascripts/relax_admin/custom.js`
Don't forget `//= stub relax_admin/custom` at the end of your `app/assets/javascripts/application.js`
Put your custom code in initCustom function, and you'r ready to go:

```javascript
$(document).on('turbolinks:load', initCustom);

function initCustom() {
}
```

### For SCSS

Create a file here `app/assets/stylesheets/relax_admin/custom.scss`

### Override View for each models or globally

Example: I wanna overrride the new view for my model `page`

In `app/views/relax_admin/models/pages/_data_new.html.erb` : (the default one)

```erb
<%= form_for [:relax_admin, @model] do |f| %>
  <%= render 'relax_admin/shared/errors_data_new' %>

  <% params.each do |a| %>
    <%= render 'relax_admin/fields/form_group', f: f, a: a %>
  <% end %>

  <%= render 'relax_admin/shared/new_form_buttons' %>
<% end %>
```

(note: `params` is `update_params` from model controller)

Example of adding column system:

```erb
<%= form_for [:relax_admin, @model] do |f| %>
  <%= render 'relax_admin/shared/errors_data_new' %>

  <div class="row">
    <div class="col-sm-6">
      <%= render 'relax_admin/fields/form_group', f: f, a: :title %>
    </div>
    <div class="col-sm-6">
      <%= render 'relax_admin/fields/form_group', f: f, a: :content %>
    </div>
  </div>

  <%= render 'relax_admin/shared/new_form_buttons' %>
<% end %>
```

Be careful, for custom type:

```erb
  <%= render 'relax_admin/fields/form_group', f: f, a: {my_color_field: {type: :color}} %>
```

## Contributing
Coming soon.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
