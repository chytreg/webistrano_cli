require 'webistrano_cli'

class Webistrano < Thor

  desc "deploy [project stage task]", "deploy project via webistrano"
  def deploy project, stage = 'staging', task = 'deploy:migrations'
    WebistranoCli.deploy project, stage, task
  end
end