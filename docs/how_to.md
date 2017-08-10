## Process to add a new model in the dashboard:

### Routes

No role or acccess security right now.
You can define `except` and `only` on ressources

```ruby
namespace :relax_admin, path: 'admin' do
  scope module: 'models' do
    resources :pages
  end
end
```

### Menu

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

Icons available:
- http://fontawesome.io/ (eg: `fa fa-home`)
- http://simplelineicons.com/ (eg: `icon-home`)

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

Eg: I wanna change the @per values:

```ruby
  def handle_default
    super # call super method to keep other instance variables
    @per = 20
  end
```
