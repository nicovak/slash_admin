require 'csv'

module RelaxAdmin
  class ModelsController < RelaxAdmin::BaseController
    before_action :handle_internal_default
    before_action :handle_default
    before_action :nestable_config
    before_action :handle_default_params
    before_action :handle_assocations

    helper_method :list_params, :export_params, :create_params, :update_params, :show_params, :nested_params

    def index
      authorize! :index, @model_class
      @models_export = if params[:filters].present?
        handle_filtered_search
      else
        @model_class.all
      end

      column = @model_class.arel_table[params[:order_field].to_sym]
      order = params[:order].downcase
      if %w(asc desc).include?(order)
        @models = @models_export.order(column.send(params[:order].downcase)).page(params[:page]).per(params[:per])
      end

      @fields = if @use_export_params
        export_params
        else
          @model_class.column_names
      end

      respond_to do |format|
        format.html
        format.csv { send_data export_csv.encode('iso-8859-1'), filename: "#{@model_name.pluralize.upcase}_#{Date.today}.csv", type: 'text/csv; charset=iso-8859-1; header=present' }
        format.xls { send_data render_to_string, filename: "#{@model_name.pluralize.upcase}_#{Date.today}.xls" }
        format.js { @models }
      end
    end

    def new
      authorize! :new, @model_class
      @model = @model_class.new
    end

    def before_validate_on_create; end
    def create
      authorize! :new, @model_class
      @model = @model_class.new(permit_params)

      before_validate_on_create

      if @model.valid?
        if @model.save!
          respond_to do |format|
            format.html do
              flash[:success] = "#{@model_name} créé(e)."
              redirect_to handle_redirect_after_submit and return
            end
            format.js { render json: @model and return }
          end
        end
      end
      respond_to do |format|
        format.html { render :new }
        format.js { render json: { errors: @model.errors.full_messages } }
      end
    end

    def edit
      authorize! :edit, @model_class
      @model = @model_class.find(params[:id])
    end

    def before_validate_on_update; end
    def update
      authorize! :edit, @model_class
      @model = @model_class.find(params[:id])

      before_validate_on_update

      if @model.update(permit_params)
        flash[:success] = "#{@model_name} mis(e) à jour."
        respond_to do |format|
          format.html { redirect_to handle_redirect_after_submit and return }
          format.js
        end
      end
      render :edit and return
    end

    def show
      authorize! :show, @model_class
      @model = @model_class.find(params[:id])

      respond_to do |format|
        format.html
        format.js { @model }
      end
    end

    def destroy
      @model_class.find(params[:id]).destroy!
      flash[:success] = "#{@model_name} supprimé(e)."
      respond_to do |format|
        format.html { redirect_to main_app.polymorphic_url([:relax_admin, @model_class]) }
        format.js
      end
    end

    def nestable
      unless @is_nestable
        flash[:error] = "Impossible de trier '#{@model_class}'"
        redirect_to main_app.polymorphic_url([:relax_admin, @model_class]) and return
      end

      if request.post?
        if params[:nestable][:data].present?
          JSON.parse(params[:nestable][:data]).each_with_index do |p, i|
            m = @model_class.find(p['id'])
            m.position = i
            m.save!
          end
        end

        flash[:success] = 'Opération réussi.'

        redirect_to main_app.polymorphic_url(['relax_admin', @model_class]) and return if params.key?(:submit_redirect)
        redirect_to main_app.polymorphic_url([:nestable, :relax_admin, @model_class])
      end
    end

    def handle_filtered_search
      search = @model_class.all

      params[:filters].each do |attr, query|
        unless query.blank?
          column = @model_class.arel_table[attr.to_sym]
          case helpers.guess_field_type(@model_class, attr)
          when 'string', 'text'
            # TODO: handle unnaccent if postgres and extensions installed
            # search = search.where("unaccent(lower(#{attr})) LIKE unaccent(lower(:query))", query: "%#{query}%")
            search = search.where(column.matches("%#{query}%"))
          when 'date', 'datetime', 'integer', 'decimal', 'number'
            if query.is_a?(String)
              search = search.where(column.eq(query))
            else
              if query['from'].present?
                search = search.where(column.gteq(query['from'].to_date))
              end
              if query['to'].present?
                search = search.where(column.lteq(query['to'].to_date))
              end
            end
          when 'boolean'
            search = search.where(column.eq(to_boolean(query)))
          when 'belongs_to', 'has_one'
            search = search.where(attr.to_s + '_id IN (' + query.join(',') + ')')
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

    def update_params(options = {})
      if (options.present?)
        create_params(options)
      else
        create_params
      end
    end

    def autocomplete_params; end

  protected

    def prepend_view_paths
      prepend_view_path 'app/views/relax_admin'
      prepend_view_path "app/views/relax_admin/models/#{@model_class.model_name.to_s.pluralize.underscore}" rescue nil
    end

    def handle_redirect_after_submit
      path =  main_app.edit_polymorphic_url(['relax_admin', @model])
      path =  main_app.polymorphic_url(['relax_admin', @model_class]) if params.key?(:submit_redirect)
      path =  main_app.new_polymorphic_url(['relax_admin', @model_class]) if params.key?(:submit_add)

      path
    end

    def permit_params
      params[@model_class.name.split('::').last.underscore].permit!
    end

    def handle_default
      @title = @model_name.present? ? @model_class.model_name.human(count: 2) : nil
      @sub_title = nil
      @per = 10
      @page = 1
      @per_values = [10, 20, 50, 100, 150]
      @use_export_params = false
      @order_field = :id
      @order = 'DESC'
    end

    def nestable_config
      @is_nestable = false
      @max_depth = 1

      @nestable_field = :position
      @acenstry_field = :ancestry
    end

    def handle_internal_default
      @model_class = model
      @model_name = @model_class.model_name.human
      @update_params = update_params
    end

    def handle_default_params
      params[:per] ||= @per
      params[:page] ||= @page
      params[:order_field] ||= @order_field
      params[:order] ||= @order
      params[:filters] ||= []
    end

    def handle_assocations
      @belongs_to_fields = @model_class.reflect_on_all_associations(:belongs_to).map(&:name)
      @has_many_fields = @model_class.reflect_on_all_associations(:has_many).map(&:name)
      @has_one_fields = @model_class.reflect_on_all_associations(:has_one).map(&:name)
    end

    # By default we are looking in RelaxAdmin:: namespace
    def model
      begin
        return controller_name.classify.constantize
      rescue
        return ('RelaxAdmin::' + controller_name.classify).constantize
      end
    end

    def create_params(options = {})
      exclude_default_params(controller_name.classify.constantize.attribute_names).map { |attr| attr.gsub(/_id$/, '') }
    end

    def show_params
      @model_class.attribute_names.map { |attr| attr.gsub(/_id$/, '') }
    end

    def nested_params
      nested_params = []
      @model_class.nested_attributes_options.keys.each do |nested|
        nested_params << { nested => exclude_default_params(nested.to_s.singularize.classify.constantize.attribute_names.map { |attr| attr.gsub(/_id$/, '') }) - [@model.model_name.param_key] }
      end

      nested_params
    end

    # Exclude default params for edit and create
    def exclude_default_params(params)
      params - %w(id created_at updated_at slug position)
    end

  private
    def list_params; end

    def export_params
      list_params
    end
  end
end
