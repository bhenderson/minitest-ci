# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "minitest-ci"
  s.version     = "3.0.4.pre"
  s.platform    = Gem::Platform::RUBY
  s.author      = "bhenderson, notnoop"
  s.email       = "sayhi@circleci.com"
  s.homepage    = "http://github.com/circleci/minitest-ci"
  s.summary     = "Minitest JUnit XML formatter"
  s.description = "Minitest Junit XML results that Hudson can read."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "minitest", '>= 5.0.6', '~> 5.0'

  s.add_development_dependency "hoe", '~> 3.15.0'
  s.add_development_dependency "rake", '~> 11.1.2'
  s.add_development_dependency "nokogiri", '~> 1.5.0'
  s.add_development_dependency 'rdoc', '>= 2.4.2'
  s.add_development_dependency 'ZenTest'

  s.files        = Dir["lib/**/*"] + %w[README.txt]
  s.require_path = "lib"
end

