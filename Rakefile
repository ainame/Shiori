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

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'shiori'
  app.device_family  = [:iphone, :ipad]
  app.frameworks = ['StoreKit']

  app.my_env.file = './app.yaml'
  app.pods do
    pod 'NanoStore'
    pod 'JASidePanels'
    pod 'HatenaBookmarkSDK', :git => 'https://github.com/hatena/Hatena-Bookmark-iOS-SDK.git'
  end
end
