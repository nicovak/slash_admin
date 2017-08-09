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
