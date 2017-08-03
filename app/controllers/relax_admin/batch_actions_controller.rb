# frozen_string_literal: true
module RelaxAdmin
  class BatchActionsController < RelaxAdmin::BaseController
    def delete
      authorize! :destroy, model
      model.where(id: params[:ids]).delete_all
    end

    def model
      constant = params[:model_class].classify.safe_constantize
      return constant if constant
    end
  end
end
