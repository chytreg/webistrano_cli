# -*- encoding: utf-8 -*-
require 'highline/import'
require 'webistrano_cli/version'
require 'webistrano_cli/task'

module WebistranoCli
  class << self
    def deploy opts = {}
      project = opts[:project]
      stage   = opts[:stage]  || 'staging'
      task    = opts[:task]   || 'deploy:migrations'

      config = {}

      [:site, :user,:password].each do |field|
        config[field] = ENV["WCLI_#{field.to_s.upcase}"]
        next if config[field]
        config[field] = ask("webistrano #{field}: ") do |q|
          q.whitespace = :strip_and_collapse
          q.validate  = lambda { |p| p.length > 0 }
          q.responses[:not_valid] = "can't be blank!"
        end
      end

      [Project, Stage, Deployment].each { |model| model.configure(config) }
      Task.new(project, stage, task).run
    end
  end
end
