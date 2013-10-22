# -*- encoding: utf-8 -*-
require 'her'
require 'faraday_middleware'
require 'multi_xml'

class HerXmlParser < Faraday::Response::ParseXml
  define_parser do |body|
    ::MultiXml.parse(body, {:disallowed_types => []})
  end

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
