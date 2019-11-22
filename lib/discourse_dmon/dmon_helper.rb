require 'net/http'
require 'uri'
require_dependency 'discourse'
module DiscourseDmon
  class DmonHelper

    def self.index_event(discourse_event)
      dmon_index(discourse_event)
    end

    def self.index_event_stats(discourse_event)
      dmon_index_stats(discourse_event)
    end

    def self.dmon_index(datas)
      server_url = SiteSetting.dmon_server_url
      server_https = SiteSetting.dmon_server_https
      uri = URI(server_url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = server_https

      request = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      request.body = ""

      request['X-Discourse-Event'] = datas.to_s
      request['X-Discourse-Hash'] = SiteSetting.dmon_server_hash.to_s
      request['X-Discourse-Url'] = "#{Discourse::base_uri}"

      response = https.request(request)
      puts response
    end

    def self.dmon_index_stats(datas)
      server_url = SiteSetting.dmon_server_url
      server_https = SiteSetting.dmon_server_https
      uri = URI(server_url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = server_https

      request = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      request.body = datas

      request['X-Discourse-Event'] = "update_stats"
      request['X-Discourse-Hash'] = SiteSetting.dmon_server_hash.to_s
      request['X-Discourse-Url'] = "#{Discourse::base_uri}"

      response = https.request(request)
      puts response
    end

    def self.guardian
      Guardian.new(User.find_by(username: SiteSetting.dmon_discourse_username))
    end
  end
end
