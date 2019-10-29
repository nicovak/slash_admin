#### WYSIWYG (using froala)

Add in your route.rb

```ruby
namespace :slash_admin, path: '/admin' do
    # FROALA (WYSIWYG)
    post   'froala_upload' => 'froala#upload'
    post   'froala_manage' => 'froala#manage'
    delete 'froala_delete' => 'froala#delete'

    scope module: 'models' do
    end
```

Create a froala dedicated controller (for image uploads and file uploads)

In `app/controllers/slash_admin/froala_controller.rb`

```ruby
# frozen_string_literal: true
module SlashAdmin
  class FroalaController < SlashAdmin::BaseController
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

Finally, in your `app/assets/javascripts/slash_admin/custom.js`

Don't forget `//= stub slash_admin/custom` at the end of your `app/assets/javascripts/application.js`

With rails uploader :

```javascript
$(document).on("turbolinks:load", initCustom);

function initCustom() {
  if ($.FroalaEditor) {
    $(".froala-editor").froalaEditor({
      height: 250,
      enter: $.FroalaEditor.ENTER_BR,
      toolbarButtons: [
        "fullscreen",
        "bold",
        "italic",
        "underline",
        "strikeThrough",
        "subscript",
        "superscript",
        "|",
        "fontFamily",
        "fontSize",
        "color",
        "inlineStyle",
        "paragraphStyle",
        "|",
        "paragraphFormat",
        "align",
        "formatOL",
        "formatUL",
        "outdent",
        "indent",
        "quote",
        "-",
        "insertLink",
        "insertImage",
        "insertVideo",
        "insertFile",
        "insertTable",
        "|",
        "emoticons",
        "specialCharacters",
        "insertHR",
        "selectAll",
        "clearFormatting",
        "|",
        "print",
        "help",
        "html",
        "|",
        "undo",
        "redo"
      ],
      pluginsEnabled: null,
      imageMove: true,
      imageDefaultDisplay: true,
      imageUploadURL: "/admin/froala_upload",
      imageUploadParam: "file",
      imageUploadParams: {
        type: "image",
        authenticity_token: $('meta[name="csrf-token"]').attr("content")
      },
      fileUploadURL: "/admin/froala_upload",
      fileUploadParam: "file",
      fileUploadParams: {
        type: "file",
        authenticity_token: $('meta[name="csrf-token"]').attr("content")
      },
      imageManagerLoadMethod: "POST",
      imageManagerLoadURL: "/admin/froala_manage",
      imageManagerLoadParams: {
        format: "json",
        authenticity_token: $('meta[name="csrf-token"]').attr("content")
      },
      imageManagerDeleteMethod: "DELETE",
      imageManagerDeleteURL: "/admin/froala_delete",
      imageManagerDeleteParams: {
        format: "json",
        authenticity_token: $('meta[name="csrf-token"]').attr("content")
      }
    });
  }
}
```

With S3 upload

add `gem 'aws-sdk-s3'` and configurer it.
add `gem 'froala-editor-sdk'`

Rename your `custom.js` to `custom.js.erb` 

Create in your `ApplicationHelper` a method `froala_s3`

```ruby
def froala_s3
  # Configuration object.
  options = {
    bucket: ENV['S3_BUCKET'],
    region: ENV['AWS_REGION'],
    keyStart: 'uploads',
    acl: 'public-read',
    accessKey: ENV['AWS_ACCESS_KEY_ID'],
    secretKey: ENV['AWS_SECRET_ACCESS_KEY']
  }

  # Compute the signature.
  FroalaEditorSDK::S3.data_hash(options)
end
```

```erb
<% environment.context_class.instance_eval { include ApplicationHelper } %>

$(document).on("turbolinks:load", initCustom);

function initCustom() {
  if ($.FroalaEditor) {
    $(".froala-editor").froalaEditor({
      // iconsTemplate: 'font_awesome_5',
      height: 250,
      enter: $.FroalaEditor.ENTER_BR,
      toolbarButtons: [
        "fullscreen",
        "bold",
        "italic",
        "underline",
        "strikeThrough",
        "subscript",
        "superscript",
        "|",
        "fontFamily",
        "fontSize",
        "color",
        "inlineStyle",
        "paragraphStyle",
        "|",
        "paragraphFormat",
        "align",
        "formatOL",
        "formatUL",
        "outdent",
        "indent",
        "quote",
        "-",
        "insertLink",
        "insertImage",
        "insertVideo",
        "insertFile",
        "insertTable",
        "|",
        "emoticons",
        "specialCharacters",
        "insertHR",
        "selectAll",
        "clearFormatting",
        "|",
        "print",
        "help",
        "html",
        "|",
        "undo",
        "redo"
      ],
      pluginsEnabled: null,
      imageMove: true,
      imageDefaultDisplay: true,
      imageUploadToS3: <%= froala_s3.to_json.html_safe %>
    });
  }
```
