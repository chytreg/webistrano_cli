# -*- encoding: utf-8 -*-
require 'active_resource'
module WebistranoCli
  class WebistranoResource < ActiveResource::Base
    self.site     = ENV['WCLI_HOST'] || 'http://webistrano.monterail.com'
    self.user     = ENV['WEBISTRANO_LOGIN']
    self.password = ENV['WEBISTRANO_PASSWORD']
  end
end