# -*- encoding: utf-8 -*-
module WebistranoCli
  class Task
    attr_accessor :log

    def initialize project_name, stage_name, task_name
      puts          "=> Select project: #{project_name}"
      @project      = Project.all.eq(project_name)
      puts          "=> Select stage: #{stage_name}"
      @stage        = @project.stages.eq(stage_name)
      @task_name    = task_name
      @log          = ""
    end

    def trigger_deployment(params)
      @deployment = Deployment.new(params)
      @deployment.save
    end

    def reload_deployment
      @deployment = Deployment.find(@deployment.id, {:project_id => @project.id, :stage_id => @stage.id})
    end

    def loop_latest_deployment
      begin
        sleep 5
        reload_deployment
        print_diff
      end while @deployment.completed_at.nil?
    end

    def print_diff
      if @deployment.try(:log)
        diff = @deployment.log
        diff.slice!(log)
        print diff
        log << diff
      end
    end

    def run
      puts "=> Get prompt config..."
      params = {
        :task          => @task_name,
        :project_id    => @project.id,
        :stage_id      => @stage.id,
        :prompt_config => @stage.prompt_task_config(@task_name)
      }

      puts "=> Task: #{@task_name}"
      trigger_deployment(params)
      loop_latest_deployment
      puts "=> Status: #{@deployment.status}"
    end

    def quiet_run(prompt_config = {})
      puts "=> Checking prompt config..."
      required_keys = @stage.get_required_config(@task_name)
      prompt_config.symbolize_keys!

      if (required_keys - prompt_config.keys).blank?

        params = {
          :task          => @task_name,
          :project_id    => @project.id,
          :stage_id      => @stage.id,
          :prompt_config => prompt_config
        }

        puts "=> Task: #{@task_name}"
        trigger_deployment(params)
        puts "=> Deploy started"
      else
        puts "=> Requied promt config to deploy: #{required_keys.join(', ')}"
        puts "=> Deploy failed "
      end
    end

  end
end