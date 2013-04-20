# -*- encoding: utf-8 -*-
require 'her'
require 'faraday_middleware'
require 'multi_xml'

# hack multi_xml parser
MultiXml.send(:remove_const, 'DISALLOWED_XML_TYPES')
MultiXml.const_set('DISALLOWED_XML_TYPES', [])

class HerXmlParser < Faraday::Response::ParseXml
  def process_response(env)
    case env[:status]
    when 200
      hash = parse(env[:body])
      hash = HashWithIndifferentAccess.new(hash)
      root = hash.keys.first
      env[:body] = {
        :data => hash[root],
        :errors => {},
        :metadata => {}
      }
    when 201
      location = env[:response_headers]['location']
      id = location.to_s.split('/').last.to_i
      env[:body] = {
        :data => {:id => id},
        :errors => {},
        :metadata => {}
      }
    end
  end
end

class HerXMLPost < Faraday::Middleware
  dependency 'active_support/all'

  def initialize(app, options={})
    @app     = app
    @options = options
  end

  def call(env)
    if [:post, :put].include?(env[:method])
      hash = env[:body]
      root = hash.keys.first
      env[:body] = (hash[root]).to_xml(:root => root)
    end
     @app.call(env)
  end
end

module Her
  class Collection
    def eq(value, field = :name)
      self.find{|p| p.send(field) =~ Regexp.new(value)}
    end
  end
end
# config setup
config = WebistranoCli::Config.new; WebistranoCli::Config.new.setup_and_load!

Her::API.setup :url => config.get_value('url') do |c|
  c.headers['Accept']       = 'application/xml'
  c.headers['Content-Type'] = 'application/xml'
  c.basic_auth config.get_value('user'), config.get_value('password')
  c.response :logger if ENV['WCLI_DEBUG']
  c.use HerXmlParser
  c.use HerXMLPost
  c.adapter Faraday.default_adapter
end