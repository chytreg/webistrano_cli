# -*- encoding: utf-8 -*-
require 'rubygems'
require 'highline/import'
require 'webistrano_cli/version'
require 'webistrano_cli/config'
require 'webistrano_cli/her_middlewares'

module WebistranoCli
  class << self

    def configure(url, user, pass, &block)
      WebistranoCli::API.setup :url => user do |c|
        c.basic_auth user, pass
        c.headers = {
          'Accept'        => 'application/xml'
          'Content-Type'  => 'application/xml'
        }
        c.response :logger if ENV['WCLI_DEBUG']
        c.use HerXmlParser
        c.use HerXMLPost
        c.adapter Faraday.default_adapter

        yield c if block_given?
      end
      require 'webistrano_cli/models'
      require 'webistrano_cli/task'
    end

    def deploy opts = {}
      Task.new(*opts.values).run
    end
  end
end