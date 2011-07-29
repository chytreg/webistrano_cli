# -*- encoding: utf-8 -*-
module WebistranoCli
  class Stage < WebistranoResource
    self.site = superclass.site + "/projects/:project_id"
    def find_task(name)
      Task.find(:all, :params => @prefix_options.merge({:stage_id => id}) ).find {|task| task.name == name}
    end
  end
end

