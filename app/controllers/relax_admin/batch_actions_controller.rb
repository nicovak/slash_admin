# frozen_string_literal: true
module RelaxAdmin
  class BatchActionsController < RelaxAdmin::BaseController
    def delete
      authorize! :destroy, model
      model.where(id: params[:ids]).delete_all
    end

    def model
      ApplicationRecord.descendants.each do |klass|
        return klass if klass == params[:model_class]
        raise Exception.new("Can't find model #{params[:model_class]}")
      end
    end
  end
end
