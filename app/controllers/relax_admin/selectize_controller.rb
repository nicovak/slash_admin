# frozen_string_literal: true
module RelaxAdmin
  class SelectizeController < RelaxAdmin::BaseController
    def show
      model_class = model
      results = model_class.all
      params[:fields].each do |f|
        column = model_class.arel_table[f.to_sym]
        results = results.where(column.matches("%#{params[:q]}%"))
      end
      render json: results
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
