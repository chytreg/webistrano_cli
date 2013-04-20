# -*- encoding: utf-8 -*-
require 'rubygems'
require 'highline/import'
require File.join(File.dirname(__FILE__), 'webistrano_cli/version')
require File.join(File.dirname(__FILE__), 'webistrano_cli/config')
require File.join(File.dirname(__FILE__), 'webistrano_cli/her_api_init')
require File.join(File.dirname(__FILE__), 'webistrano_cli/project')
require File.join(File.dirname(__FILE__), 'webistrano_cli/stage')
require File.join(File.dirname(__FILE__), 'webistrano_cli/task')
require File.join(File.dirname(__FILE__), 'webistrano_cli/deployment')

module WebistranoCli
  class << self
    def deploy opts = {}
      # config setup
      config = Config.new
      Config.new.setup_and_load!
      Task.new(opts[:project], config.stage(opts[:stage]), config.task(opts[:task])).run
    end
  end
end