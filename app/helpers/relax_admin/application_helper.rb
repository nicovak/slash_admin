# frozen_string_literal: true
module RelaxAdmin
  module ApplicationHelper
    def menu_entries
      [
        {
          title: 'Dashboard',
          path: dashboard_path,
          icon: 'icon-home',
        },
      ]
    end

    def page_title(content)
      content_for :page_title, content
    end

    def page_sub_title(content)
      content_for :page_sub_title, content
    end

    def required?(obj, name)
      obj.class.validators_on(name).any? { |v| v.is_a? ActiveModel::Validations::PresenceValidator }
    end

    def show_errors(object, field_name)
      return [] if object.errors.empty?
      unless object.errors.messages[field_name].blank?
        return object.errors.messages[field_name]
      end
      []
    end

    def errors?(object, field_name)
      return false if object.errors.empty?
      return true unless object.errors.messages[field_name].blank?
    end

    def toastr_bootstrap
      flash_messages = []
      flash.each do |type, message|
        text = "<script>toastr.#{type}('#{message}');</script>"
        flash_messages << text.html_safe if message
      end
      flash_messages.join("\n").html_safe
    end

    # Default available field_type handeled
    def orderable?(attr, model_class)
      field_type = guess_field_type(attr, model_class)
      %w(boolean integer number decimal string text date datetime).include?(field_type)
    end

    # By default all sortable fields are orderable
    def sortable?(attr, model_class)
      orderable?(attr, model_class)
    end

    # Automatic retrieve of field type
    # boolean integer number decimal string text date datetime has_many belongs_to
    def guess_field_type(attr, model_class)
      # Specific field
      type = if model_class&.uploaders&.key?(attr.to_sym)
               'image'
             elsif @belongs_to_fields.include?(attr.to_sym)
               'belongs_to'
             elsif @has_many_fields.include?(attr.to_sym)
               'has_many'
             else
               model_class.type_for_attribute(attr.to_s).type.to_s
             end

      # Virtual field default string eg password
      return 'string' if type.blank? && @model&.respond_to?(attr)

      # Raise exception if no type fouded
      raise Exception.new("Unable to guess field_type for attribute: #{attr} in model: #{model_class}") if type.blank?
      type
    end

    # Form helper for field
    def admin_field(form, attribute, model_class)
      # Handle specific field first and default after
      if @belongs_to_fields.include?(attribute.to_sym)
        render partial: 'fields/belongs_to', locals: {f: form, a: attribute}
      elsif @has_many_fields.include?(attribute.to_sym)
        # if has nested_attributes_options for has_many field
        if model_class.nested_attributes_options.key?(attribute.to_sym)
          render partial: 'fields/nested_has_many', locals: {f: form, a: attribute}
        else
          render partial: 'fields/has_many', locals: {f: form, a: attribute}
        end
      elsif model_class&.uploaders&.key?(attribute.to_sym)
        render partial: 'fields/carrierwave', locals: {f: form, a: attribute}
      else
        # Default fields
        case guess_field_type(attribute, model_class)
        when 'string'
          render partial: 'fields/string', locals: {f: form, a: attribute}
        when 'text'
          render partial: 'fields/text', locals: {f: form, a: attribute}
        when 'integer'
          render partial: 'fields/integer', locals: {f: form, a: attribute}
        when 'number', 'decimal'
          render partial: 'fields/number', locals: {f: form, a: attribute}
        when 'boolean'
          render partial: 'fields/boolean', locals: {f: form, a: attribute}
        when 'date', 'datetime'
          render partial: 'fields/date', locals: {f: form, a: attribute}
        end
      end
    end
  end
end