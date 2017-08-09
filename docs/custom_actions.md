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
