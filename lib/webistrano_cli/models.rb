# -*- encoding: utf-8 -*-
require 'mechanize'

module WebistranoCli

  class Deployment
    include Her::Model
    uses_api WebistranoCli::API
    collection_path "projects/:project_id/stages/:stage_id/deployments"
    include_root_in_json :deployment
  end

  class Project
    include Her::Model
    uses_api WebistranoCli::API
    has_many :stages
  end

  class Stage
    include Her::Model
    uses_api WebistranoCli::API
    belongs_to :project

    def tasks
      Task.all(:_project_id => self.project_id, :_stage_id => self.id)
    end

    def get_task_config(name)
      prompt_config = {}
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Safari'

      login_page = agent.get("http://example.com/sessions/new")
      login_page.form_with(:action => '/sessions') { |f|
        f.login = 'login'
        f.password = 'password'
      }.submit

      task_page = agent.get("http://example.com/projects/#{project_id}/stages/#{id}/deployments/new?task=#{name}")

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
