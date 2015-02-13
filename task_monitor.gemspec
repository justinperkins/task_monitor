# -*- encoding: utf-8 -*-
require File.expand_path('../lib/task_monitor/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'task_monitor'
  s.version     = TaskMonitor::VERSION
  s.date        = '2015-02-12'
  s.summary     = "Hook for rake tasks to report they are running"
  s.description = "Reporting for rake tasks running and managing alerts"
  s.authors     = ["Justin Perkins"]
  s.email       = 'hello@thumber6.com'
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.homepage    =
    'http://rubygems.org/gems/task_monitor'
  s.license       = 'MIT'

  s.add_dependency "fog", "~ 1.14"
  s.add_dependency "json", "~ 1.8"
  s.add_dependency "tzinfo", "~ 1.2"
end