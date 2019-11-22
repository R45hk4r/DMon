# name: discourse-dmon
# about:
# version: 0.2
# authors: Discourse-monitoring
# url: https://github.com/imMMX


gem 'json', '2.2.0'
gem 'httpclient', '2.8.3'

enabled_site_setting :dmon_enabled

PLUGIN_NAME ||= "discourse-dmon".freeze

after_initialize do
  load File.expand_path('../lib/discourse_dmon/dmon_helper.rb', __FILE__)

  # see lib/plugin/instance.rb for the methods available in this context


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



  DiscourseDmon::Engine.routes.draw do
    get "/list" => "actions#list"
  end

  Discourse::Application.routes.append do
    mount ::DiscourseDmon::Engine, at: "/discourse-dmon"
  end

  [:user_created, :user_updated, :topic_created, :topic_edited, :topic_destroyed, :topic_recovered, :post_created, :post_edited, :post_destroyed, :post_recovered].each do |discourse_event|
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
