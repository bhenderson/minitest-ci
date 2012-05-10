require 'minitest/unit'
#unless MiniTest::Unit::VERSION >= '2.12.0'
unless MiniTest::Unit.public_method_defined? :record
  abort 'you are running an unsupported version of MiniTest. try upgrading.'
end

require 'fileutils'
require 'cgi'

module MiniTest
  module Ci

    VERSION = '2.1.0'

    @suites = Hash.new {|h,k| h[k] = []}

    class << self
      # Accessor method to change the report dir if you don't like the
      # defaults.
      attr_accessor :report_dir

      # Clean the report_dir between test runs? (defaults to true)
      attr_accessor :auto_clean
    end
    self.report_dir = 'test/reports'
    self.auto_clean = true

    def push suite, method, num_assertions, time, error
      @suites[suite] << [method, num_assertions, time, error]
    end

    def finish io
      io.puts
      io.puts 'generating ci files'

      clean

      Dir.chdir report_dir do
        @suites.each do |name, suite|
          generate_suite name, suite
        end
      end
    end

    def clean verbose = false
      FileUtils.rm_rf report_dir, :verbose => verbose if auto_clean
      FileUtils.mkdir_p report_dir, :verbose => verbose
    end

    private

    def escape o
      CGI.escapeHTML(o.to_s)
    end

    def generate_suite name, suite
      total_time = assertions = errors = failures = skips = 0
      suite.each do |_, a, t, e|
        total_time += t
        assertions += a
        case e
        when MiniTest::Skip
          skips += 1
        when MiniTest::Assertion
          failures += 1
        else
          errors += 1
        end
      end

      File.open "TEST-#{name}.xml", "w" do |f|
        f.puts '<?xml version="1.0" encoding="UTF-8"?>'
        f.puts "<testsuite time='#{"%6f" % total_time}' skipped='#{skips}' failures='#{failures}' errors='#{errors}' name='#{name}' assertions='#{assertions}' tests='#{suite.count}'>"

        suite.each do |method, asserts, time, error|
          f.puts "  <testcase time='#{"%6f" % time}' name='#{method}' assertions='#{asserts}'>"
          if error
            bt = MiniTest::filter_backtrace error.backtrace
            f.write "    <#{type error} type='#{escape error.class}' message=#{escape( error.message ).inspect}>"
            f.puts escape bt.join "\n"
            f.puts "    </#{type error}>"
          end
          f.puts "  </testcase>"
        end

        f.puts "</testsuite>"
      end
    end

    def type e
      case e
      when MiniTest::Skip
        'skipped'
      else
        'failure'
      end
    end

    extend self
  end

  class CiUnit < Unit

    after_tests do
      MiniTest::Ci.finish self.output
    end

    def record suite, method, assertions, time, error
      MiniTest::Ci.push suite, method, assertions, time, error
      super
    end

  end
end

# use
MiniTest::Unit.runner = MiniTest::CiUnit.new
