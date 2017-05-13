class RelaxAdmin::BatchActionsController < Admin::BaseController
  def delete
    model.where(id: params[:ids]).delete_all
  end

  def handle_default
    @model_class = model
  end

  def model
    params[:model_class].classify.constantize
  end

  def look_for_association
  end
end
