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
Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'shiori'
  app.device_family  = :ipad

  app.pods do
    pod 'NanoStore'
    pod 'JASidePanels'
  end
end
