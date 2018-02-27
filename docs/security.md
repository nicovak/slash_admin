## Handle permission with [cancancan](https://github.com/CanCanCommunity/cancancan)

Just run `rails g slash_admin:permissions` and edit the generated file according [docs](https://github.com/CanCanCommunity/cancancan/wiki/defining-abilities)

## Override admin model or sessions_controller

You can override the default logic for authentication, and you can modify the default admin model.

```bash
rails g slash_admin:override_session
rails g slash_admin:override_admin
```
