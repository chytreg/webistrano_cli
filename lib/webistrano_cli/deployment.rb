# -*- encoding: utf-8 -*-
require 'mechanize'
module WebistranoCli
  class Deployment < ActiveResource::Base

    def self.configure(config)
      self.site     = config[:site] + "/projects/:project_id/stages/:stage_id"
      self.user     = config[:user]
      self.password = config[:password]
    end

    def self.get_prompt_config(project_id, stage_id, task)
      prompt_config = {}
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Safari'

      login_page = agent.get("#{Project.site}/sessions/new")
      login_page.form_with(:action => '/sessions') { |f|
        f.login = self.user
        f.password = self.password
      }.submit

      task_page = agent.get("#{Project.site}/projects/#{project_id}/stages/#{stage_id}/deployments/new?task=#{task}")

      deploy_form = task_page.form_with(:action => /deployments/, :method => /post/i)

      deploy_form.fields_with(:name => /prompt_config/).each do |field|
        field.name.match(/(\w+)\]$/)
        prompt_config[$1.to_sym] = ask("=> Set #{$1}: ") do |q|
          q.whitespace = :strip_and_collapse
          q.validate  = lambda { |p| p.length > 0 }
          q.responses[:not_valid] = "#{field.name} => can't be blank!"
        end
      end
      prompt_config.presence
    end
  end
end