require Rails.root.join('app', 'services', 'uptime', 'adapters', 'pingdom')

module Admin
  class UptimeChecksController < Admin::ApplicationController
    def index
      return unless HostEnv.live?

      @without_checks = services_without_uptime_checks
      @with_uptime_checks = with_uptime_checks
      @non_editor_checks = non_editor_service_checks
    end

    def create
      service_id = params[:id]
      latest_metadata = MetadataApiClient::Service.latest_version(service_id)
      service = MetadataPresenter::Service.new(latest_metadata, editor: true)
      Uptime.new(
        service_id: service.service_id,
        service_name: service.service_name,
        host: "#{service_slug(service)}.#{url_root}",
        adapter:
      ).create

      redirect_to admin_uptime_checks_path
    end

    def destroy
      Uptime.new(check_id: params[:id], adapter:).destroy

      redirect_to admin_uptime_checks_path
    end

    def services_without_uptime_checks
      checks = without_uptime_checks.map do |uuid|
        latest_metadata = MetadataApiClient::Service.latest_version(uuid)
        MetadataPresenter::Service.new(latest_metadata, editor: true)
      end

      checks.sort_by(&:service_name)
    end

    def without_uptime_checks
      @without_uptime_checks ||=
        published_services_uuids.reject { |uuid| uuid.in?(uptime_check_tag_uuids) }.uniq
    end

    def with_uptime_checks
      @with_uptime_checks ||= begin
        checks = uptime_checks.select do |check|
          check['tags'].any? do |tag|
            tag['name'].in?(published_services_uuids)
          end
        end

        checks.sort_by { |check| check['name'] }
      end
    end

    def uptime_check_tag_uuids
      @uptime_check_tag_uuids ||=
        with_uptime_checks.map { |c| c['tags'].map { |t| t['name'] } }.flatten
    end

    def uptime_checks
      @uptime_checks ||= Uptime::Adapters::Pingdom.new.checks
    end

    def published_services_uuids
      @published_services_uuids ||= published('production').map(&:service_id)
    end

    def non_editor_service_checks
      existing_check_ids = with_uptime_checks.map { |c| c['id'] }
      checks = uptime_checks.reject do |check|
        check['id'].in?(existing_check_ids) ||
          check['tags'].any? do |tag|
            tag.in?(with_uptime_checks) || tag.in?(without_uptime_checks)
          end
      end

      checks.sort_by { |check| check['name'] }
    end

    def url_root
      Rails.application.config.platform_environments[ENV['PLATFORM_ENV']][:url_root]
    end

    def adapter
      Uptime::Adapters::Pingdom
    end

    def service_slug_config(service_id)
      ServiceConfiguration.find_by(
        service_id:,
        deployment_environment: 'dev',
        name: 'SERVICE_SLUG'
      )&.decrypt_value
    end

    def service_slug(service)
      service_slug_config(service.service_id).presence || service.service_slug
    end
    helper_method :service_slug
  end
end
