# -*- encoding: utf-8 -*-
require 'yaml'
module WebistranoCli
  class Config

    def initialize
      @file_path = File.expand_path('~/.webistrano_cli.yml')
      if File.exists?(@file_path)
        @config = YAML.load_file(@file_path) rescue nil
      else
        @config = nil
      end
    end

    def get
      config = {}

      [:site, :user,:password].each do |field|
        config[field] = ENV["WCLI_#{field.to_s.upcase}"] || (@config['webistrano_cli'][field.to_s] rescue nil)
        next if config[field]
        config[field] = ask("webistrano #{field}: ") do |q|
          q.whitespace = :strip_and_collapse
          q.validate  = lambda { |p| p.length > 0 }
          q.responses[:not_valid] = "can't be blank!"
        end
      end

      File.open(@file_path, 'w') do |f|
        obj = {
          'webistrano_cli' => {
            'site' => config[:site],
            'user' => config[:user],
            'password' => config[:password],
            'defaults' => {
              'stage' => 'staging',
              'task'  => 'deploy:migrations'
            }
          }
        }
        YAML.dump obj, f
      end unless File.exists?(@file_path)
      config
    end

    def stage opt
      opt || (@config['webistrano_cli']['defaults']['stage'] rescue nil) || 'staging'
    end

    def task opt
      opt || (@config['webistrano_cli']['defaults']['task'] rescue nil) || 'deploy:migrations'
    end

  end
end