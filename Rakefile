# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'

if ARGV.join(' ') =~ /spec/
  Bundler.require(:default, :development)
else
  Bundler.require
end

ENV['output'] = 'test_unit'
#ENV['ARR_DEBUG'] = '1'

pixate_setting = YAML.load(open('./pixate_license.yaml').read)
Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'shiori'
  app.device_family  = :ipad

  app.pixate.user = pixate_setting['user']
  app.pixate.key  = pixate_setting['key']
  app.pixate.framework = 'vendor/PXEngine.framework'
  app.my_env.file = './app.yaml'

  app.pods do
    pod 'NanoStore'
    pod 'JASidePanels'
    pod 'HatenaBookmarkSDK', :git => 'https://github.com/hatena/Hatena-Bookmark-iOS-SDK.git'
  end
end
