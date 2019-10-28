# frozen_string_literal: true

module SlashAdmin
  class BatchActionsController < SlashAdmin::BaseController
    def delete
      authorize! :destroy, model
      model.where(id: params[:ids]).delete_all
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
