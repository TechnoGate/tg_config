# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tg_config/version"

Gem::Specification.new do |s|
  s.name        = "tg_config"
  s.version     = TechnoGate::TgConfig.version
  s.authors     = ["Wael Nasreddine"]
  s.email       = ["wael.nasreddine@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A simple YAML configuration reader and writer}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")

  ####
  # Run-time dependencies
  ####

  # Bundler
  s.add_dependency 'bundler', '~>1.0.0'

  # Active Support
  s.add_dependency 'activesupport', '~>3.1.1'
  s.add_dependency 'i18n'

  ####
  # Development dependencies
  ####

  # Guard
  s.add_development_dependency 'guard', '~>0.8.4'
  s.add_development_dependency 'guard-bundler', '~>0.1.3'
  s.add_development_dependency 'guard-rspec', '~>0.4.5'

  # Documentation
  s.add_development_dependency 'yard', '~>0.7.2'

  ####
  # Development / Test dependencies
  ####

  # RSpec / Capybara
  s.add_development_dependency 'rspec', '~>2.6.0'

  # Mocha
  s.add_development_dependency 'mocha', '~>0.10.0'

  ####
  # Debugging
  ####
  s.add_development_dependency 'pry', '~>0.9.6.2'
end
