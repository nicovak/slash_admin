#### WYSIWYG


### SELECT YOUR WYSIWYG 
## 1) Froala

Add css to your slash_admin/custom.scss
```css
@import "https://cdnjs.cloudflare.com/ajax/libs/froala-editor/2.6.0/css/froala_editor.pkgd.min.css";
@import "https://cdnjs.cloudflare.com/ajax/libs/froala-editor/2.6.0/css/froala_style.min.css";
```

Override the slash_admin layout and add the froala js
```ruby
<%= javascript_include_tag "https://cdnjs.cloudflare.com/ajax/libs/froala-editor/2.8.4/js/froala_editor.pkgd.min.js" %>
```

Add js to your slash_admin/custom.js
```javascript
$(document).on("turbolinks:load", initCustom);

function initCustom() {
  if ($.FroalaEditor) {
    $(".wysiwyg-editor").froalaEditor({
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
      imageUploadURL: "/admin/wysiwyg_upload",
      imageUploadParam: "file",
      imageUploadParams: {
        type: "image",
        authenticity_token: $('meta[name="csrf-token"]').attr("content")
      },
      fileUploadURL: "/admin/wysiwyg_upload",
      fileUploadParam: "file",
      fileUploadParams: {
        type: "file",
        authenticity_token: $('meta[name="csrf-token"]').attr("content")
      },
      imageManagerLoadMethod: "POST",
      imageManagerLoadURL: "/admin/wysiwyg_manage",
      imageManagerLoadParams: {
        format: "json",
        authenticity_token: $('meta[name="csrf-token"]').attr("content")
      },
      imageManagerDeleteMethod: "DELETE",
      imageManagerDeleteURL: "/admin/wysiwyg_delete",
      imageManagerDeleteParams: {
        format: "json",
        authenticity_token: $('meta[name="csrf-token"]').attr("content")
      }
    });
  }
}
```

## 2) or Summernote

Add css to your slash_admin/custom.scss
```css
@import "https://cdnjs.cloudflare.com/ajax/libs/summernote/0.8.10/summernote.css";
```

Override the slash_admin layout and add the summernote js
```ruby
<%= javascript_include_tag "https://cdnjs.cloudflare.com/ajax/libs/summernote/0.8.10/summernote.min.js" %>
```

Add js to your slash_admin/custom.js

```javascript
$(document).on("turbolinks:load", initCustom);

function initCustom() {
    var deleteFile, initSummernote, sendFile;
    sendFile = function(that, file) {
        var data;
        data = new FormData;
        data.append('file', file);
        data.append('type', 'image');
        data.append('authenticity_token', $('meta[name="csrf-token"]').attr("content"));
        return $.ajax({
            data: data,
            type: 'POST',
            url: '/admin/wysiwyg_upload',
            cache: false,
            contentType: false,
            processData: false,
            success: function(data) {
                var img;
                img = document.createElement('IMG');
                img.src = data.link;
                img.setAttribute('id', data.filename);
                return $(that).summernote('insertNode', img);
            }
        });
    };

    deleteFile = function(filename) {
        return $.ajax({
            type: 'DELETE',
            url: '/admin/wysiwyg_delete?src=' + filename,
            cache: false,
            contentType: false,
            processData: false
        });
    };

    initSummernote = function() {
        return $('.wysiwyg-editor').each(function() {
            return $(this).summernote({
                height: 200,
                callbacks: {
                    onImageUpload: function(files) {
                        var img;
                        return img = sendFile(this, files[0]);
                    },
                    onMediaDelete: function(target, editor, editable) {
                        var image_id;
                        image_id = target[0].id;
                        if (!!image_id) {
                            deleteFile(image_id);
                        }
                        return target.remove();
                    }
                }
            });
        });
    };
    initSummernote();
}
```


## 3) Configuration (Froala or Summernote)
Add in your route.rb

```ruby
namespace :slash_admin, path: '/admin' do
    # WYSIWYG
    post   'wysiwyg_upload' => 'wysiwyg#upload'
    delete 'wysiwyg_delete' => 'wysiwyg#delete'
    post   'wysiwyg_manage' => 'wysiwyg#manage' # only FROALA
    ...

    scope module: 'models' do
      ...
    end
```

Create a wysiwyg dedicated controller (for image uploads and file uploads)

In `app/controllers/slash_admin/wysiwyg_controller.rb`

```ruby
# frozen_string_literal: true
module SlashAdmin
  class WysiwygController < SlashAdmin::BaseController
    def upload
      uploader = WysiwygUploader.new(params[:type].pluralize)
      uploader.store!(params[:file])

      respond_to do |format|
        format.json do 
          render json: { status: 'OK', link: uploader.url } 
        end
      end
    end

    def delete
      # FROALA
      filename = params[:src].split('/').last
      # SUMMERNOTE
      filename = params[:src]
      
      file_path = "uploads/wysiwyg/images/#{filename}"
      path = "#{Rails.root}/public/#{file_path}"

      FileUtils.rm(path)

      respond_to do |format|
        format.json { render json: {status: 'OK'} }
      end
    end

    # only FROALA
    def manage
      files = []

      file_path = "uploads/wysiwyg/images"
      real_file_path = "#{request.headers['HTTP_ORIGIN']}/uploads/wysiwyg/images/"
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
      attr_accessor :url, :thumb, :tag # t:thumb, :tag only FROALA
    end
  end
end
```

In `app/uploaders/wysiwyg_uploader.rb`

```ruby
class WysiwygUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/wysiwyg/#{mounted_as}"
  end
  
end
```

Don't forget `//= stub slash_admin/custom` at the end of your `app/assets/javascripts/application.js`
