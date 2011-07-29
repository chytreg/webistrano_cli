require "webistrano_cli/webistrano_resource"
require "webistrano_cli/project"
require "webistrano_cli/stage"
require "webistrano_cli/deployment"

module WebistranoCli
  class Task
    attr_accessor :log

    def initialize project, stage, task
      puts      "=> Select project: #{project}"
      @project  = Project.find_by_name(project)
      puts      "=> Select stage: #{stage}"
      @stage    = @project.find_stage(stage)
      @task     = task
      @log      = ""
    end

    def loop_latest_deployment
      prefix_options = @deployment.prefix_options
      begin
        sleep 5
        @deployment.prefix_options.merge!(prefix_options)
        @deployment.reload
        print_diff(@deployment)
      end while @deployment.completed_at.nil?
    end

    def print_diff(deployment)
      if deployment.log
        diff = deployment.log
        diff.slice!(log)
        print diff
        log << diff
      end
    end

    def run
      puts "=> Get prompt config..."
      params = {
        :task => @task,
        :project_id => @project.id,
        :stage_id => @stage.id,
        :prompt_config => Deployment.get_prompt_config(@project.id, @stage.id, @task)
      }
      puts "=> Task: #{@task}"
      @deployment = Deployment.create(params)
      loop_latest_deployment
      puts "=> Status: #{@deployment.status}"
    end

  end
end