# -*- encoding: utf-8 -*-
require 'mechanize'
module WebistranoCli
  class Deployment
    include Her::Model
    collection_path "projects/:project_id/stages/:stage_id/deployments"
    include_root_in_json :deployment
  end
end