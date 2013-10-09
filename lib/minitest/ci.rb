require 'fileutils'
require 'cgi'

module Minitest
  class Ci

    VERSION = '3.0.2'

    class << self

      ##
      # Accessor method to change the report dir if you don't like the
      # defaults.

      attr_accessor :report_dir

      ##
      # Clean the report_dir between test runs? (defaults to true)

      attr_accessor :clean
    end

    self.report_dir = 'test/reports'
    self.clean      = true

    attr_accessor :io
    attr_accessor :options
    attr_accessor :results

    def initialize io = $stdout, options = {}
      self.io      = io
      self.options = options
      self.results = Hash.new {|h,k| h[k] = []}
    end

    def passed?
      true # don't care?
    end

    def start # clean
      FileUtils.rm_rf   report_dir if clean?
      FileUtils.mkdir_p report_dir
    end

    def record result
      results[result.class] << result
    end

    def report
      io.puts
      io.puts 'generating ci files'

      Dir.chdir report_dir do
        results.each do |name, resultz|
          File.open "TEST-#{CGI.escape(name.to_s)}.xml", "w" do |f|
            f.puts generate_results name, resultz
          end
        end
      end
    end

    private

    def escape o
      CGI.escapeHTML(o.to_s)
    end

    def generate_results name, results
      total_time = assertions = errors = failures = skips = 0
      results.each do |result|
        total_time += result.time
        assertions += result.assertions
        # p result.failure.class
        case result.failure
        when Skip
          skips += 1
        when UnexpectedError
          errors += 1
        when Assertion
          failures += 1
        end
      end

      xml = []

      xml << '<?xml version="1.0" encoding="UTF-8"?>'
      xml << "<testsuite time='%6f' skipped='%d' failures='%d' errors='%d' name='%s' assertions='%d' tests='%d'>" %
        [total_time, skips, failures, errors, escape(name), assertions, results.count]

      results.each do |result|
        xml << "  <testcase time='%6f' name='%s' assertions='%s'>" %
          [result.time, escape(result.name), result.assertions]
        if failure = result.failure
          label = failure.result_label.downcase

          if failure.is_a?(UnexpectedError)
            failure = failure.error
          end

          klass = failure.class
          msg   = failure.message
          bt    = Minitest::filter_backtrace failure.backtrace

          xml << "    <%s type='%s' message=%s>%s" %
            [label, escape(klass), escape(msg).inspect, escape(bt.join("\n"))]
          xml << "    </%s>" % label
        end
        xml << "  </testcase>"
      end

      xml << "</testsuite>"

      xml
    end

    def report_dir
      options.fetch(:ci_dir, self.class.report_dir)
    end

    def clean?
      options.fetch(:ci_clean, self.class.clean)
    end

  end
end
