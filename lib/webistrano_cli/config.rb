# -*- encoding: utf-8 -*-
require 'yaml'
module WebistranoCli
  class Config

    def initialize
      @file_path  = File.expand_path('~/.webistrano_cli.yml')
      @config     = YAML.load_file(@file_path) rescue nil
    end

    def load!(path)
      @config  = YAML.load_file(path)
    end

    def setup_and_load!
      return @config if @config.presence
      config = {}
      # read config from ENV or ask for it
      ['url', 'user', 'password'].each do |field|
        config[field] = ENV["WCLI_#{field.upcase}"]
        next if config[field]
        config[field] = ask("webistrano #{field}: ", String) do |q|
          q.whitespace = :strip_and_collapse
          q.validate  = lambda { |p| p.length > 0 }
          q.responses[:not_valid] = "can't be blank!"
        end
      end
      @config = {'webistrano_cli' =>  config}
      save_yaml
    end

    def stage opt
      opt || get_value('defaults/stage') || 'staging'
    end

    def task opt
      opt || get_value('defaults/task') || 'deploy:migrations'
    end

    def get_value(path)
      nested = path.to_s.split('/')
      current = @config['webistrano_cli']
      nested.each do |key|
        current = current[key]
      end
      current
    rescue
      nil
    end

    def save_yaml
      return @config if File.exists?(@file_path)
      File.open(@file_path, 'w') do |file|
        YAML.dump({
          'webistrano_cli' => {
            'url' => @config['url'].to_s,
            'user' => @config['user'].to_s,
            'password' => @config['password'].to_s,
            'defaults' => {
              'stage' => 'staging',
              'task'  => 'deploy:migrations'
            }
          }
        }, file)
      end
      @config
    end

  end
end