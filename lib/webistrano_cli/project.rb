module WebistranoCli
  class Project < WebistranoResource
    def self.find_by_name(name)
      project = find(:all).find {|project| project.name == name}
    end

    def find_stage(name)
      Stage.find(:all, :params => {:project_id => id}).find {|stage| stage.name == name}
    end
  end
end