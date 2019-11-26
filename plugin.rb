# name: DMon
# about:
# version: 0.1.1
# authors: Discourse-monitoring.com
# url: https://github.com/R45hk4r/DMon


gem 'json', '2.2.0'
gem 'httpclient', '2.8.3'

enabled_site_setting :dmon_enabled

PLUGIN_NAME ||= "discourse-dmon".freeze

after_initialize do
  load File.expand_path('../lib/discourse_dmon/dmon_helper.rb', __FILE__)

  module ::DiscourseDmon
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseDmon
    end
  end

  require_dependency File.expand_path('../app/jobs/regular/update_dmon_event.rb', __FILE__)
  require_dependency File.expand_path('../app/jobs/regular/update_dmon_stats.rb', __FILE__)
  require_dependency 'discourse_event'


  require_dependency "application_controller"
  class DiscourseDmon::ActionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in

    def list
      render json: success_json
    end
  end


  [:topic_created, :topic_destroyed, :topic_recovered, :topic_edited, :post_created, :post_edited, :post_destroyed, :post_recovered, :user_created, :user_approved, :user_updated, :user_logged_out, :user_logged_in, :user_destroyed, :category_created, :category_updated, :category_destroyed, :group_created, :group_updated, :group_destroyed, :tag_created, :tag_updated, :tag_destroyed, :notification_created, :reviewable_created, :reviewable_transitioned_to].each do |discourse_event|
    DiscourseEvent.on(discourse_event) do |event|
      if SiteSetting.dmon_enabled?
        Jobs.enqueue_in(0,
                        :update_dmon_event,
                        discourse_event: discourse_event
        )
      end
    end
  end
end
