### Techs

- Rails >= 5
- Bootstrap >= 4
- Ruby >= 2.4.0

### Dashboard
- [X] Charts
- [X] Easy widget system
- [X] I18n
- [X] Globalize and local based model
- [ ] Global search
- [X] Integration of roles and permission with [cancancan](https://github.com/CanCanCommunity/cancancan)

### Create / Edit
- [X] Default params for create
- [X] Handling form and helpers

### List
- [X] Default export of model (excel and csv)
- [X] Filter system + search based on data type
- [X] Batch action
- [X] Pagination
- [X] Handle `has_one`, `belongs_to`, `has_many`
- [X] Sortable and nested list
- [X] Better handling of field type

### Miscellaneous

- [ ] Tests
- [ ] Heroku Demo
- [ ] Wiki
- [X] Docs

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
- [X] `has_one`
- [X] nested `has_one`
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
- [X] Google Map
- [X] nested `belongs_to`
- [X] Tags (string delimited with ';', ',', '.', ' ')

### How to ?

[Read the docs](https://github.com/nicovak/relax_admin/tree/master/docs/how_to.md)
