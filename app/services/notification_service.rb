require 'net/http'
require 'uri'

class NotificationService
  def self.notify(message)
    body = {
      text: message,
      username: 'MOJ Forms Editor',
      icon_emoji: ':rockon:'
    }

    uri = URI.parse(ENV['SLACK_PUBLISH_WEBHOOK'])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = body.to_json

    http.request(request)
  end
end
