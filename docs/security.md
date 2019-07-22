## Handle permission with [cancancan](https://github.com/CanCanCommunity/cancancan)

Just run `rails g slash_admin:permissions` and edit the generated file according [docs](https://github.com/CanCanCommunity/cancancan/wiki/defining-abilities)

eg

```ruby
module SlashAdmin
  class AdminAbility
    include CanCan::Ability

    def initialize(user)
      @user = user
      if user.has_role?('superadmin')
        can :manage, :all
      elsif user.has_role?('admin')
        can :manage, :all
        cannot :manage, SlashAdminAdmin
      elsif user.has_role?('my_role')
        # eg of direct path
        can :my_custom_role, :my_custom_role
        # eg of model
        can :manage, Post
      end
    end
  end
end
```

## Override admin model or sessions_controller

You can override the default logic for authentication, and you can modify the default admin model.

```bash
rails g slash_admin:override_session
rails g slash_admin:override_admin
```
