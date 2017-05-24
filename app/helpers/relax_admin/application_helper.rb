# frozen_string_literal: true
module RelaxAdmin
  module ApplicationHelper
    def page_title(content)
      content_for :page_title, content
    end

    def page_sub_title(content)
      content_for :page_sub_title, content
    end

    # is the current has access to one node
    def access?(s)
      if s[:sub_menu].present?
        s[:sub_menu].each do |sub|
          return false if !access_model?(sub)
        end
      end
      true
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

    def show_errors(field_name)
      if field_name.is_a?(Hash)
        field_name = field_name.keys.first
      end
      return [] if @model.errors.empty?
      unless @model.errors.messages[field_name].blank?
        return @model.errors.messages[field_name]
      end
      []
    end

    def errors?(field_name)
      if field_name.is_a?(Hash)
        field_name = field_name.keys.first
      end
      return false if @model.errors.empty?
      return true unless @model.errors.messages[field_name].blank?
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
    def orderable?(attr)
      field_type = guess_field_type(attr)
      %w(boolean integer number decimal string text date datetime).include?(field_type)
    end

    # By default all sortable fields are orderable
    def sortable?(attr)
      orderable?(attr)
    end

    # Automatic retrieve of field type
    # boolean integer number decimal string text date datetime has_many belongs_to
    def guess_field_type(attr)
      # Specific field
      type = if @model_class&.uploaders&.key?(attr.to_sym)
               'image'
             elsif @belongs_to_fields.include?(attr.to_sym)
               'belongs_to'
             elsif @has_many_fields.include?(attr.to_sym)
               'has_many'
             else
               @model_class.type_for_attribute(attr.to_s).type.to_s
             end

      # Virtual field default string eg password
      return 'string' if type.blank? && @model&.respond_to?(attr)

      # Raise exception if no type fouded
      raise Exception.new("Unable to guess field_type for attribute: #{attr} in model: #{model_class}") if type.blank?
      type
    end

    def admin_custom_field(form, attribute)
      type = attribute[attribute.keys.first][:type].to_s
      render partial: "relax_admin/custom_fields/#{type}", locals: {f: form, a: attribute}
    end

    # Form helper for generic field
    def admin_field(form, attribute)
      # Handle custom field first and default after
      is_custom = attribute.is_a?(Hash)
      if is_custom
        admin_custom_field(form, attribute)
      elsif @belongs_to_fields.include?(attribute.to_sym)
        render partial: 'relax_admin/fields/belongs_to', locals: {f: form, a: attribute}
      elsif @has_many_fields.include?(attribute.to_sym)
        # if has nested_attributes_options for has_many field
        if @model_class.nested_attributes_options.key?(attribute.to_sym)
          render partial: 'relax_admin/fields/nested_has_many', locals: {f: form, a: attribute}
        else
          render partial: 'relax_admin/fields/has_many', locals: {f: form, a: attribute}
        end
      elsif @model_class&.uploaders&.key?(attribute.to_sym)
        render partial: 'relax_admin/fields/carrierwave', locals: {f: form, a: attribute}
      else
        # Default fields
        case guess_field_type(attribute)
        when 'string'
          render partial: 'relax_admin/fields/string', locals: {f: form, a: attribute}
        when 'text'
          render partial: 'relax_admin/fields/text', locals: {f: form, a: attribute}
        when 'integer'
          render partial: 'relax_admin/fields/integer', locals: {f: form, a: attribute}
        when 'number', 'decimal'
          render partial: 'relax_admin/fields/number', locals: {f: form, a: attribute}
        when 'boolean'
          render partial: 'relax_admin/fields/boolean', locals: {f: form, a: attribute}
        when 'date', 'datetime'
          render partial: 'relax_admin/fields/date', locals: {f: form, a: attribute}
        end
      end
    end
  end
end
