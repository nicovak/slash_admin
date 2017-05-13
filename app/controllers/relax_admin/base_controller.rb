module RelaxAdmin
  class BaseController < RelaxAdmin::ApplicationController
    before_action :authenticate_admin!
    before_action :handle_default
    before_action :handle_default_mode
    before_action :handle_default_params
    before_action :look_for_association
    before_action :prepend_view_paths

    helper_method :list_params, :export_params, :create_params, :update_params, :show_params, :nested_params, :current_admin, :object_label

    def index
      @models_export = if params[:filters].present?
                         handle_filtered_search
                       else
                         @model_class.all
                       end

      @models = @models_export.order("#{params[:order_field]} #{params[:order]}").page(params[:page]).per(params[:per])

      @fields = if @use_export_params
                  export_params
                else
                  @model_class.column_names
                end

      respond_to do |format|
        format.html
        format.csv { send_data export_csv.encode('iso-8859-1'), filename: "#{@model_name.pluralize.upcase}_#{Date.today}.csv", type: 'text/csv; charset=iso-8859-1; header=present' }
        format.xls { send_data render_to_string, filename: "#{@model_name.pluralize.upcase}_#{Date.today}.xls" }
      end
    end

    def new
      @model = @model_class.new
    end

    def create
      @model = @model_class.new(permit_params)
      if @model.valid?
        if @model.save
          flash[:success] = "#{@model_name} créé(e)."
          redirect_to(action: :index) && return if params[:submit_redirect]
          redirect_to(action: :new) && return if params[:submit_add]
          redirect_to edit_polymorphic_path([:admin, @model])
        end
      else
        render action: 'new'
      end
    end

    def edit
      @model = @model_class.find(params[:id])
    end

    def show
      @model = @model_class.find(params[:id])
    end

    def update
      if @model_class.find(params[:id]).update(permit_params)
        flash[:success] = "#{@model_name} mis(e) à jour."
        redirect_to(action: :index) && return if params[:submit_redirect]
        redirect_to action: :edit
      else
        render action: :edit
      end
    end

    def destroy
      @model_class.find(params[:id]).destroy!

      flash[:success] = "#{@model_name} supprimé(e)."
      redirect_to action: :index, flash: {notice: "#{@model_name} supprimé(e)."}
    end

    def object_label_methods
      [:title, :name]
    end

    def handle_filtered_search
      search = @model_class.all

      params[:filters].each do |attr, query|
        unless query.blank?
          case helpers.guess_field_type(attr, @model_class)
          when 'string', 'text'
              # search = search.where("unaccent(lower(#{attr})) LIKE unaccent(lower(:query))", query: "%#{query}%")
              search = search.where("lower(#{attr}) LIKE lower(:query)", query: "%#{query}%")
          when 'date', 'datetime', 'integer', 'decimal', 'number'
            if query.is_a?(String)
              search = search.where("#{attr} = :query", query: query)
            else
              search = search.where("#{attr} >= :query", query: query['from']) if query['from'].present?
              search = search.where("#{attr} <= :query", query: query['to']) if query['to'].present?
            end
          when 'boolean'
            search = search.where("#{attr} = :query", query: to_boolean(query))
          end
        end
      end

      search
    end

    # Export CSV
    def export_csv(options = {})
      CSV.generate(options) do |csv|
        header = @fields.map { |f| @model_class.human_attribute_name(f) }
        csv << header
        @models_export.each do |m|
          csv << m.attributes.values_at(*@fields)
        end
        csv
      end
    end

    # Default label for object to string, title and name
    def object_label(a)
      constantized_model = a.to_s.singularize.classify.constantize
      method = 'to_s'

      object_label_methods.each do |m|
        method = m if constantized_model.has_attribute?(m)
      end

      method
    end

  protected

    def permit_params
      params[@model_class.model_name.to_s.underscore].permit!
    end

    def handle_default
      @sub_title = nil
      @per = 10
      @page = 1
      @per_values = [10, 20, 50, 100, 150]
      @model_class = model
      @model_name = @model_class.model_name.human
      @use_export_params = false
      @order_field = :id
      @order = 'DESC'
    end

    def handle_default_params
      params[:per] ||= @per
      params[:page] ||= @page
      params[:order_field] ||= @order_field
      params[:order] ||= @order
      params[:filters] ||= []
    end

    def look_for_association
      @belongs_to_fields = @model_class.reflect_on_all_associations(:belongs_to).map(&:name)
      @has_many_fields = @model_class.reflect_on_all_associations(:has_many).map(&:name)
    end

    def model
      controller_name.classify.constantize
    end

    def handle_default_mode
      session[:compact] ||= false
    end

  private
    def authenticate_admin!
      return true if current_admin.present?
      flash[:error] = 'Vous devez êtres connecté pour accéder à cette page.'
      redirect_to login_url unless controller_name == 'sessions'
    end

    def current_admin
      @current_admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
    end

    def prepend_view_paths
      prepend_view_path 'app/views/relax_admin'
      prepend_view_path "app/views/relax_admin/models/#{@model_class.model_name.to_s.pluralize.underscore}" rescue nil
    end

    def to_boolean(str)
      str == 'true'
    end

    def should_load_layout_data?
      false
    end

    def list_params
    end

    def export_params
      list_params
    end

    def create_params
      exclude_default_params(@model_class.attribute_names).map { |attr| attr.gsub('_id', '') }
    end

    def update_params
      exclude_default_params(create_params)
    end

    def show_params
      @model_class.attribute_names.map { |attr| attr.gsub('_id', '') }
    end

    def nested_params
      nested_params = []
      @model_class.nested_attributes_options.keys.each do |nested|
        nested_params << {nested => exclude_default_params(nested.to_s.singularize.classify.constantize.attribute_names.map { |attr| attr.gsub('_id', '') }) - [@model.model_name.param_key]}
      end

      nested_params
    end

    # Exclude default params for edit and create
    def exclude_default_params(params)
      params - %w(id created_at updated_at slug)
    end
  end
end
