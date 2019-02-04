# frozen_string_literal: true

# :params
# :model_class
# :field
# :q
module SlashAdmin
  class SelectizeController < SlashAdmin::BaseController
    def search
      model_class = model
      if model_class.respond_to? :translated_attribute_names
        results = model_class.with_translations(I18n.locale).all
      else
        results = model_class.all
      end

      duplicate_for_orwhere = results

      virtual_fields = []

      params[:fields].each_with_index do |f, index|
        if model_class.respond_to? :translated_attribute_names
          if model_class.translated_attribute_names.include?(f.to_sym)
            f = "#{params[:model_class].singularize.underscore}_translations.#{f}"
          end
        else
          unless model_class.column_names.include?(f) || model_class.respond_to?(f)
            raise Exception.new("Unable to find attribute: #{f} in model_column: #{model_class}, you may need to override autocomplete_params in you target's model controller")
          end
        end

        if index == 0
          if model_class.column_names.include?(f)
            results = results.where("lower(#{f}) LIKE lower(:query)", query: "%#{params[:q]}%")
          else
            virtual_fields << f
          end
        else
          results = results.or(duplicate_for_orwhere.where("lower(#{f}) LIKE lower(:query)", query: "%#{params[:q]}%"))
        end
      end

      params[:fields].each do |f|
        unless params[:q].blank?
          if virtual_fields.present? && virtual_fields.include?(f)
            results = results.select { |s| s.send(f).present? ? s.send(f).downcase.include?(params[:q].downcase) : nil }
          end
        end
      end



      formatted_result = []
      results.each do |r|
        formatted_result << { id: r.id, name: helpers.show_object(r) }
      end

      render json: formatted_result
    end

    def model
      ActiveRecord::Base.connection.tables.map do |klass|
        testing_class = klass.capitalize.singularize.camelize
        return testing_class.constantize if testing_class == params[:model_class].capitalize.singularize.camelize
      end
      raise Exception.new("Can't find model #{params[:model_class]}")
    end
  end
end
