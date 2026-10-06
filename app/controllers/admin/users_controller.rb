module Admin
  # rubocop:disable Rails/LexicallyScopedActionFilter, Naming/MemoizedInstanceVariableName
  class UsersController < Admin::ApplicationController
    before_action :assign_user_services, only: :show

    def default_sorting_attribute
      :name
    end

    def assign_user_services
      @user_services ||= MetadataApiClient::Service.all(user_id: params[:id])
    end

    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    def index
      authorize_resource(resource_class)
      search_term = params[:search].to_s.strip.downcase
      # Because our data is encrypted in the db we can't search using where
      # LIKE - so we have to force Administrate to not search.
      resources = filter_resources(scoped_resource, search_term: '')
      resources = apply_collection_includes(resources)
      resources = order.apply(resources)

      # If there's a search term we need to filter the returned data using
      # select. Otherwise we apply DB pagination
      resources = if search_term.present?
                    found = resources.select { |resource| resource.name.downcase.include?(search_term) || resource.email.downcase.include?(search_term) }
                    Kaminari.paginate_array(found).page(params[:_page]).per(records_per_page)
                  else
                    paginate_resources(resources)
                  end

      page = Administrate::Page::Collection.new(dashboard, order:)
      filters = Administrate::Search.new(scoped_resource, dashboard, search_term).valid_filters

      render locals: {
        resources:,
        search_term:,
        page:,
        show_search_bar: show_search_bar?,
        filters:
      }
    end
    #
    # def update
    #   super
    #   send_foo_updated_email(requested_resource)
    # end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # The result of this lookup will be available as `requested_resource`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    # def scoped_resource
    #   if current_user.super_admin?
    #     resource_class
    #   else
    #     resource_class.with_less_stuff
    #   end
    # end

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    # def resource_params
    #   params.require(resource_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes).
    #     transform_values { |value| value == "" ? nil : value }
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
  # rubocop:enable Rails/LexicallyScopedActionFilter, Naming/MemoizedInstanceVariableName
end
