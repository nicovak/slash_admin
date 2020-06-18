## Process to add a new model in the dashboard:

### Routes

You can define `except` and `only` on ressources.
You can use `cancancan` for roles and permission [docs](https://github.com/nicovak/slash_admin/blob/master/docs/security.md)

```ruby
namespace :slash_admin, path: "/admin" do
  scope module: 'models' do
    resources :pages
  end
end
```

### Menu

```ruby
module SlashAdmin
  class MenuHelper
    def menu_entries
      [
        {
          title: 'Dashboard',
          path: slash_admin.dashboard_path,
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

Icons available:
- http://fontawesome.io/ (eg: `fas fa-home`)
- http://simplelineicons.com/ (eg: `icon-home`)

## Sample controller (mandatory), in `app/controllers/slash_admin/models` folder

For references see: app/controllers/admin/models_controller.rb and app/controllers/admin/base_controller.rb
Everything is overridable for each controller and each model (params, views, field, etc)

**def list_params method is mandatory**

You can generate an admin controller (e.g for page model):

```bash
rails g slash_admin:controllers pages
```

```ruby
module SlashAdmin
  module Models
    class PagesController < SlashAdmin::ModelsController
      def list_params
        [
          { image: { type: :image } },
          :title,
        ]
      end
    end
  end
end
```

### Available and most commons usage

In controller:

#### Change default config ####

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

```ruby
def handle_default
  super # call super method to keep other instance variables
  @per = 20
end
```

#### Add Tooltip ####

```ruby
def tooltips
{
  my_attr: "My Content",
}
end
```

Filters in list view for `belongs_to` and `has_one relations`, In the target controller:
(eg: a post belongs_to a category)

In `PostssController`:

```ruby
def list_params
  [
    :category,
    :title,
  ]
end
```

In `CategoriesController`:

```ruby
def autocomplete_params
  [
    :title
  ]
end
```

By default, autocomplete_params will take `:name` or `:title` column for search target.
Override this method to add any column you are looking for.

`before_validate_on_create` and `before_validate_on_update` are ready to use methods for adding logic before persist.

```ruby
def before_validate_on_update
  params[:polymorphic_user]['user_attributes'].delete(:password) if params[:polymorphic_user]['user_attributes'][:password].blank?
end
```

### Translatable models ###

You must use and set up [globalize gem](https://github.com/globalize/globalize)
This gem allows you to translate your model.
All translated attibutes must not be in the original model. According docs, you will have these translatable attributes in the created table.
Don't forget validations.

In your model:

```ruby
class Page < ApplicationRecord
  translates :title
  accepts_nested_attributes_for :translations

  class Translation
    validates :title, presence: true
  end
end
```

In controller (for custom type eg: `image`, `wysiwyg` ...)

```ruby
module SlashAdmin
  module Models
    class PagesController < SlashAdmin::ModelsController
      def translatable_params
        [
          { image: { type: :image } },
          :title,
        ]
      end
    end
  end
end
```

SlashAdmin will use the first locale in your `I18n.available_locales` as default.
You can change this behavior in `config/initializers/slash_admin.rb`
You can also override it for each model. For example, you can override the method available_locales in your model's controller :

```ruby
def available_locales
  # By Default it uses SlashAdmin.available_locales
  # Which is by default I18n.available_locales
  %w(fr en ja zh)
end
```

In `config/application.rb`

```ruby
config.i18n.available_locales = %w(fr en)
```

You may want to use this [gem](https://github.com/iain/http_accept_language) to handle locale in front.
