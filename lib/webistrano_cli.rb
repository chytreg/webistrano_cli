# -*- encoding: utf-8 -*-
require 'highline/import'
require 'webistrano_cli/version'
require 'webistrano_cli/config'
require 'webistrano_cli/her_middlewares'

module WebistranoCli
  API = Her::API.new

  class << self
    attr_accessor :url, :user, :pass

    def configure(url, user, pass, &block)
      @url = url; @user = user; @pass = pass
      WebistranoCli::API.setup :url => url do |c|
        c.headers['Accept']       = 'application/xml'
        c.headers['Content-Type'] = 'application/xml'
        c.basic_auth user, pass
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