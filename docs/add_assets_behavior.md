### For JS

Create a file here `app/assets/javascripts/slash_admin/custom.js`
Don't forget `//= stub slash_admin/custom` at the end of your `app/assets/javascripts/application.js`
Put your custom code in initCustom function, and you'r ready to go:

```javascript
$(document).on('turbolinks:load', initCustom);

function initCustom() {
}
```

### For SCSS

Create a file here `app/assets/stylesheets/slash_admin/custom.scss`
