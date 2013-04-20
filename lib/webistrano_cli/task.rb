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

    def loop_latest_deployment
      begin
        sleep 5
        @deployment = Deployment.find(@deployment.id, {:project_id => @project.id, :stage_id => @stage.id})
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
        :task          => @task_name,
        :project_id    => @project.id,
        :stage_id      => @stage.id,
        :prompt_config => @stage.get_task_config(@task_name)
      }

      puts "=> Task: #{@task_name}"
      @deployment = Deployment.new(params)
      @deployment.save
      loop_latest_deployment
      puts "=> Status: #{@deployment.status}"
    end

  end
end