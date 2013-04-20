# -*- encoding: utf-8 -*-
module WebistranoCli
  class Project
    include Her::Model
    has_many :stages
  end
end