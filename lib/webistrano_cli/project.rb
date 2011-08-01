# -*- encoding: utf-8 -*-
module WebistranoCli
  class Project < ActiveResource::Base

    def self.configure(config)
      self.site     = config[:site]
      self.user     = config[:user]
      self.password = config[:password]
    end

    def self.find_by_name(name)
      project = find(:all).find {|project| project.name == name}
    end

    def find_stage(name)
      Stage.find(:all, :params => {:project_id => id}).find {|stage| stage.name == name}
    end
  end
end