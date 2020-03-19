#### WYSIWYG

Add in your route.rb

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
                        return sendFile(this, files[0]);
                    },
                    onMediaDelete: function(target, editor, editable) {
                        var image_id = target[0].id;
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

## 3) Configuration
Add in your route.rb

```ruby
namespace :slash_admin, path: '/admin' do
    # WYSIWYG
    post   'wysiwyg_upload' => 'wysiwyg#upload'
    delete 'wysiwyg_delete' => 'wysiwyg#delete'
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
      filename = params[:src]
      
      file_path = "uploads/wysiwyg/images/#{filename}"
      path = "#{Rails.root}/public/#{file_path}"

      FileUtils.rm(path)

      respond_to do |format|
        format.json { render json: {status: 'OK'} }
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
