# frozen_string_literal: true
module RelaxAdmin
  class BatchActionsController < RelaxAdmin::BaseController
    def delete
      authorize! :destroy, model
      model.where(id: params[:ids]).delete_all
    end

    def model
      params[:model_class].classify.constantize
    end
  end
end
