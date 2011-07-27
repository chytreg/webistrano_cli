require 'rubygems'
require 'thor'
require 'highline/import'
require 'mechanize'
require 'awesome_print'

class Webistrano < Thor

  desc "deploy [project stage task]", "deploy project via webistrano"
  def deploy project, stage = 'staging', task = 'deploy:migrations'
    @settings = {
      :host     => 'http://webistrano.monterail.com',
      :login    => ENV['WEBISTRANO_LOGIN'],
      :password => ENV['WEBISTRANO_PASSWORD']
    }

    @settings[:login] = ask("webistrano user: ") do |q|
      q.whitespace = :strip_and_collapse
      q.validate  = lambda { |p| p.length > 0 }
      q.responses[:not_valid] = "can't be blank!"
    end unless @settings[:login]

    @settings[:password] = ask("webistrano password: ") do |q|
      q.whitespace = :strip_and_collapse
      q.validate  = lambda { |p| p.length > 0 }
      q.responses[:not_valid] = "can't be blank!"
    end unless @settings[:password]

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'

    login_page = agent.get("#{@settings[:host]}/sessions/new")
    puts "=> Sign in"
    login_page.form_with(:action => '/sessions') { |f|
      f.login = @settings[:login]
      f.password = @settings[:password]
    }.submit

    puts "=> Fetch projects"
    projects_page = agent.get("#{@settings[:host]}/projects")

    puts "=> Select project: #{project}"
    project_page  = projects_page.link_with(:text => project).click

    puts "=> Select stage: #{stage}"
    stage_page    = project_page.link_with(:text => stage).click

    puts "=> Select task: #{task}"
    task_page = stage_page.link_with(:href => /task=#{task}/).click
    deploy_form = task_page.form_with(:action => /deployments/, :method => /post/i)

    deploy_form.fields_with(:name => /prompt_config/).each do |field|
      field.value = ask("#{field.name}: ") do |q|
        q.whitespace = :strip_and_collapse
        q.validate  = lambda { |p| p.length > 0 }
        q.responses[:not_valid] = "#{field.name} => can't be blank!"
      end
    end

    puts "=> Deploy form submit"
    deploy_page = deploy_form.submit

    status = nil
    begin
      sleep 5 if status
      status_page = agent.get deploy_page.uri.to_s
      status = status_page.parser.css('#status_info .deployment_status').text.gsub(/[^\w: ]|^\s+|\s+$/, '').gsub(/\s+/, ' ')
      puts "=> #{status}"
    end while (status !~ /success|failed/i)

    puts "=> open #{deploy_page.uri.to_s}" if status =~ /repeat/i
    puts "=> Finish"
  end
end