##
# Plugin for Autotest to ignore MiniTest::Ci report directory.
#
# in your .autotest file:
#
# require 'autotest/minitest_ci'
#
# # optionally:
# Autotest::MiniTestCI.report_dir = 'some/other/path/to/reports'
#
# I think this plugin can do more than what it does now, but not sure yet.
# Leaving here to think about it more.
module Autotest::MiniTestCI
  class << self
    attr_accessor :report_dir
  end
  # MiniTest::Ci.report_dir which is configurable in your test suite is not
  # accessible to autotest so we just have to make it duplicated here. If
  # anyone has any good suggestions other than evaling a file etc. I'm open.
  self.report_dir = 'test/reports'

  # tell autotest to ignore the report directory.
  Autotest.add_hook :initialize do |at|
    at.add_exception Autotest::MiniTestCI.report_dir
  end
end
