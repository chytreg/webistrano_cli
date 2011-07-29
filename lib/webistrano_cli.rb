# -*- encoding: utf-8 -*-
require 'highline/import'
require 'webistrano_cli/task'
require 'webistrano_cli/version'

module WebistranoCli
  class << self
    def deploy project, stage = 'staging', task = 'deploy:migrations'
      # @settings = {
      #   :host     => 'http://webistrano.monterail.com',
      #   :login    => ENV['WEBISTRANO_LOGIN'],
      #   :password => ENV['WEBISTRANO_PASSWORD']
      # }
      #
      # @settings[:login] = ask("webistrano user: ") do |q|
      #   q.whitespace = :strip_and_collapse
      #   q.validate  = lambda { |p| p.length > 0 }
      #   q.responses[:not_valid] = "can't be blank!"
      # end unless @settings[:login]
      #
      # @settings[:password] = ask("webistrano password: ") do |q|
      #   q.whitespace = :strip_and_collapse
      #   q.validate  = lambda { |p| p.length > 0 }
      #   q.responses[:not_valid] = "can't be blank!"
      # end unless @settings[:password]
      Task.new(project, stage, task).run
    end
  end
end

# WebistranoCli.deploy 'mm4-hoovers'
