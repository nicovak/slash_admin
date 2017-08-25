# frozen_string_literal: true
module RelaxAdmin
  module ApplicationHelper
    def page_title(content)
      content_for :page_title, content
    end

    def page_sub_title(content)
      content_for :page_sub_title, content
    end

    # is the current has access to at least one node
    def access?(s)
      access = false
      if s[:sub_menu].present?
        s[:sub_menu].each do |sub|
          access = true if access_model?(sub)
        end
      end

      # Direct Link temp TODO
      if s[:path].present?
        access = true
      end
      access
    end

    # is the current has access to model
    def access_model?(sub)
      return false if cannot? :index, sub[:model]
      true
    end

    def required?(obj, field_name)
      if field_name.is_a?(Hash)
        field_name = field_name.keys.first
      end

      obj.class.validators_on(field_name.to_s).any? { |v| v.is_a? ActiveModel::Validations::PresenceValidator }
    end

    def show_hidden_errors
      @model.errors.messages.except(*@update_params)
    end

    def show_errors(form, field_name)
      object = form.object
      if field_name.is_a?(Hash)
        field_name = field_name.keys.first
      end
      return [] if object.errors.empty?
      unless object.errors.messages[field_name].blank?
        return object.errors.messages[field_name]
      end
      []
    end

    def errors?(form, field_name)
      object = form.object
      if field_name.is_a?(Hash)
        field_name = field_name.keys.first
      end
      return false if object.errors.empty?
      return true unless object.errors.messages[field_name].blank?
    end

    def toastr_bootstrap
      flash_messages = []
      flash.each do |type, message|
        text = '<script data-turbolinks-eval="false">toastr.' + type + '("' + message + '");</script>'
        flash_messages << text.html_safe if message
      end
      flash_messages.join("\n").html_safe
    end

    # Default available field_type handeled
    def orderable?(object, attr)
      field_type = guess_field_type(object, attr)
      %w(boolean integer number decimal string text date datetime).include?(field_type)
    end

    # By default all sortable fields are orderable
    def sortable?(object, attr)
      orderable?(object, attr)
    end

    def object_label_methods
      [:title, :name]
    end

    # Default label for object to string, title and name
    # can be an attribute, a string or the model_class
    def object_label(a)
      if a.is_a? Hash
        constantized_model = a.keys.first.to_s.singularize.classify.constantize
      elsif a.is_a? ActiveRecord::Base
        constantized_model = a
      else
        constantized_model = a.to_s.singularize.classify.constantize
      end

      method = 'to_s'
      object_label_methods.each do |m|
        method = m if constantized_model.has_attribute?(m)
      end

      method
    end

    def show_object(a)
      method = 'to_s'

      unless a.blank?
        object_label_methods.each do |m|
          method = m if a.has_attribute?(m)
        end

        a.send(method)
      end
    end

    # Automatic retrieve of field type
    # object params can be a Model Class or a Model Instance
    # boolean integer number decimal string text date datetime has_many belongs_to
    def guess_field_type(object, attr)
      if object.class === Class
        object_class = object
      else
        object_class = object.class
      end
      belongs_to_fields = object_class.reflect_on_all_associations(:belongs_to).map(&:name)
      has_many_fields = object_class.reflect_on_all_associations(:has_many).map(&:name)

      type = if object_class&.uploaders&.key?(attr.to_sym)
        'image'
      elsif belongs_to_fields.include?(attr.to_sym)
        'belongs_to'
      elsif has_many_fields.include?(attr.to_sym)
        'has_many'
      else
        object_class.type_for_attribute(attr.to_s).type.to_s
      end

      # Virtual field default string eg password
      return 'string' if type.blank? && object&.respond_to?(attr)

      # Raise exception if no type fouded
      raise Exception.new("Unable to guess field_type for attribute: #{attr} in model: #{object_class}") if type.blank?
      type
    end

    def admin_custom_field(form, attribute)
      type = attribute[attribute.keys.first][:type].to_s
      render partial: "relax_admin/custom_fields/#{type}", locals: { f: form, a: attribute }
    end

    # Form helper for generic field
    def admin_field(form, attribute)
      object_class = form.object.class
      belongs_to_fields = object_class.reflect_on_all_associations(:belongs_to).map(&:name)
      has_many_fields = object_class.reflect_on_all_associations(:has_many).map(&:name)

      # Handle custom field first and default after
      if attribute.is_a?(Hash)
        admin_custom_field(form, attribute)
      elsif belongs_to_fields.include?(attribute.to_sym)
        render partial: 'relax_admin/fields/belongs_to', locals: { f: form, a: attribute }
      elsif has_many_fields.include?(attribute.to_sym)
        # if has nested_attributes_options for has_many field
        if form.object.class.nested_attributes_options.key?(attribute.to_sym)
          render partial: 'relax_admin/fields/nested_has_many', locals: { f: form, a: attribute }
        else
          render partial: 'relax_admin/fields/has_many', locals: { f: form, a: attribute }
        end
      elsif form.object.class&.uploaders&.key?(attribute.to_sym)
        render partial: 'relax_admin/fields/carrierwave', locals: { f: form, a: attribute }
      elsif type == Date || DateTime
        render partial: 'relax_admin/fields/date', locals: { f: form, a: attribute }
      else
        type = form.object.class.type_for_attribute(attribute.to_s).type.to_s
        render partial: "relax_admin/fields/#{type}", locals: { f: form, a: attribute }
      end
    end
  end
end
