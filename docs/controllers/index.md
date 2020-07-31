## Filtering serialized arrays

Sometimes you want to store arrays in a string field. They can be filtered by specifying it in the `ModelsController` like so:

```ruby
module SlashAdmin
  module Models
    class PagesController < SlashAdmin::ModelsController
      def list_params
        [
          :title,
          { tags: { type: :badge }, filter: :string }
        ]
      end
    end
  end
end
```

And create a custom partial in `app/views/slash_admin/models/pages/_badge.html.erb`:

```erb
<% model.tags.each do |tag| %>
  <span class="badge badge-pill badge-info"><%= tag %></span>
<% end %>
```

The `filter` key specifies which field format the SQL query much use. For now, only `:string` and `:text` are available.
