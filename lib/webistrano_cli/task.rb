# -*- encoding: utf-8 -*-
module WebistranoCli
  class Task
    attr_accessor :log

    def initialize project_name, stage_name, task_name
      WebistranoCli.logger.info "=> Select project: #{project_name}"
      @project      = Project.all.eq(project_name)
      WebistranoCli.logger.info "=> Select stage: #{stage_name}"
      @stage        = @project.stages.eq(stage_name)
      @task_name    = task_name
      @log          = ""
    end

    def trigger_deployment(params)
      params.delete(:prompt_config) if params[:prompt_config].blank?
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
      WebistranoCli.logger.info "=> Get prompt config..."
      params = {
        :task          => @task_name,
        :project_id    => @project.id,
        :stage_id      => @stage.id,
        :prompt_config => @stage.prompt_task_config(@task_name)
      }

      WebistranoCli.logger.info "=> Task: #{@task_name}"
      trigger_deployment(params)
      loop_latest_deployment
      WebistranoCli.logger.info "=> Status: #{@deployment.status}"
    end

    def quiet_run(prompt_config = {})
      WebistranoCli.logger.info "=> Checking prompt config..."
      required_keys = @stage.get_required_config(@task_name)
      prompt_config.symbolize_keys!

      if (required_keys - prompt_config.keys).blank?

        params = {
          :task          => @task_name,
          :project_id    => @project.id,
          :stage_id      => @stage.id,
          :prompt_config => prompt_config
        }

        WebistranoCli.logger.info "=> Task: #{@task_name}"
        trigger_deployment(params)
        WebistranoCli.logger.info "=> Deploy started"
      else
        WebistranoCli.logger.info "=> Requied promt config to deploy: #{required_keys.join(', ')}"
        WebistranoCli.logger.info "=> Deploy failed "
      end
    end

  end
end