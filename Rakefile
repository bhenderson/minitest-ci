# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :isolate
Hoe.plugin :version, :git

Hoe.spec 'minitest-ci' do
  developer 'Brian Henderson', 'bhenderson@attinteractive.com'

  self.testlib = :none

  extra_deps << ['minitest', '~> 3.0']
  extra_dev_deps << ['nokogiri', '~> 1.5.0']
  extra_dev_deps << ['rdoc',     '>= 2.4.2']
  extra_dev_deps << ['ZenTest']
end

# vim: syntax=ruby
