# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'

Bundler.require

is_test = ARGV.join(' ') =~ /spec/
if is_test
  require 'guard/motion'
  Bundler.require :default, :spec
else
  Bundler.require
end

class Exception
  def backtrace
    []
  end
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'shiori'
  app.device_family = :ipad
end
