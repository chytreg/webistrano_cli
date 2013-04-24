# -*- encoding: utf-8 -*-
require 'logger'
require 'highline/import'
require 'webistrano_cli/version'
require 'webistrano_cli/config'
require 'webistrano_cli/her_middlewares'

module WebistranoCli
  API = Her::API.new

  class << self
    attr_accessor :url, :user, :pass, :logger

    def configure(url, user, pass, &block)
      @url = url; @user = user; @pass = pass
      @logger = ::Logger.new(STDOUT)
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

    def logger=(value)
      @logger = value if value.is_a?(Logger)
    end

    def deploy opts = {}
      Task.new(opts[:project], opts[:stage], opts[:task]).run
    end
  end

end