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

    def deploy_form_for(task_name)
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Safari'

      login_page = agent.get("#{WebistranoCli.url}/sessions/new")
      login_page.form_with(:action => '/sessions') { |f|
        f.login     = WebistranoCli.user
        f.password  = WebistranoCli.pass
      }.submit

      task_page = agent.get("#{WebistranoCli.url}/projects/#{project_id}/stages/#{id}/deployments/new?task=#{name}")
      task_page.form_with(:action => /deployments/, :method => /post/i)
    end

    def prompt_task_config(task_name)
      prompt_config = {}

      deploy_form_for(task_name).fields_with(:name => /prompt_config/).each do |field|
        field.name.match(/(\w+)\]$/)
        prompt_config[$1.to_sym] = ask("=> Set #{$1}: ") do |q|
          q.whitespace = :strip_and_collapse
          q.validate  = lambda { |p| p.length > 0 }
          q.responses[:not_valid] = "#{field.name} => can't be blank!"
        end
      end
      prompt_config
    end

    def get_required_config(task_name)
      required_keys = []
      deploy_form_for(task_name).fields_with(:name => /prompt_config/).each do |field|
        field.name.match(/(\w+)\]$/)
        required_keys << $1.to_sym
      end
      required_keys.compact
    end

  end

end
