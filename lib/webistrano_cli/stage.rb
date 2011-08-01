# -*- encoding: utf-8 -*-
module WebistranoCli
  class Stage < ActiveResource::Base

    def self.configure(config)
      self.site     = config[:site] + "/projects/:project_id"
      self.user     = config[:user]
      self.password = config[:password]
    end

    def find_task(name)
      Task.find(:all, :params => @prefix_options.merge({:stage_id => id}) ).find {|task| task.name == name}
    end
  end
end

