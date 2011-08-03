# -*- encoding: utf-8 -*-
require 'highline/import'
require 'webistrano_cli/version'
require 'webistrano_cli/config'
require 'webistrano_cli/task'

module WebistranoCli
  class << self
    def deploy opts = {}
      config = Config.new
      config_hash = Config.new.get
      [Project, Stage, Deployment].each { |model| model.configure(config_hash) }
      Task.new(
        opts[:project],
        config.stage(opts[:stage]),
        config.stage(opts[:task])
      ).run
    end
  end
end
