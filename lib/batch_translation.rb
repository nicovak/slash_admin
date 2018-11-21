# Do not forget to set accepts_nested_attributes_for :translations in the translated model.

module ActionView
  module Helpers
    class FormBuilder
      def globalize_fields_for(locale, *args, &proc)
        raise ArgumentError, 'Missing block' unless block_given?
        options = args.extract_options!
        @index = @index ? @index + 1 : 1
        object_name = "#{@object_name}[translations_attributes][#{@index}]"
        form_object = @object || @object_name.to_s.camelize.constantize.new
        object = form_object.translations.select { |t| t.locale.to_s == locale.to_s }.first
        @template.concat @template.hidden_field_tag("#{object_name}[id]", object ? object.id : '')
        @template.concat @template.hidden_field_tag("#{object_name}[locale]", locale)
        @template.fields_for(object_name, object, options, &proc)
      end
    end
  end
end
