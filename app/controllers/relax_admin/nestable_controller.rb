# frozen_string_literal: true
module RelaxAdmin
  class NestableController < RelaxAdmin::BaseController
    def index
      
    end

    def handle_process
    end

    def handle_default
      @model_class = model
    end

    def model
      params[:model_class].classify.constantize
    end

    def look_for_association; end
  end
end
