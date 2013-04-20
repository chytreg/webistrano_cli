# -*- encoding: utf-8 -*-
module WebistranoCli
  class Project
    include Her::Model
    uses_api WebistranoCli::API
    has_many :stages
  end
end