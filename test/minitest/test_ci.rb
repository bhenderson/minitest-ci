gem 'minitest'
require "minitest/autorun"
require "minitest/ci"

require 'stringio'
require 'nokogiri'

class MockTestSuite < Minitest::Test
  def test_raise_error
    raise 'raise an error'
  end

  def test_fail_assertion
    flunk 'fail assertion'
  end

  def test_skip_assertion
    skip 'skip assertion'
  end

  def test_pass
    pass
  end

  def test_invalid_characters_in_message
    raise Object.new.inspect
  end

  def test_invalid_error_name
    raise Class.new(Exception)
  end

  def test_escaping_failure_message
    flunk "failed: doesn't like single or \"double\" quotes or symbols such as <"
  end
end

SpecWithPunctuation = describe "spec/with::punctuation" do
 it "passes" do
   pass
 end
end

# better way?
$ci_io = StringIO.new
Minitest::Ci.clean = false

# setup test files
reporter = Minitest::Ci.new $ci_io
reporter.run_and_report do
  Minitest.__run reporter, {}
end

Minitest::Runnable.reset

class TestMinitest; end
class TestMinitest::TestCi < Minitest::Test

  def output
    $ci_io
  end

  def setup
    file = "test/reports/TEST-MockTestSuite.xml"
    @file = File.read file
    @doc = Nokogiri.parse @file
    @doc = @doc.at_xpath('/testsuite')
  end

  def test_testsuite
    assert_equal "1", @doc['skipped']
    assert_equal "2", @doc['failures']
    assert_equal "3", @doc['errors']
    assert_equal "3", @doc['assertions']
    assert_equal "7", @doc['tests']
    assert_equal "MockTestSuite", @doc['name']
  end

  def test_testcase_count
    assert_equal 7, @doc.children.count {|c| Nokogiri::XML::Element === c}
    @doc.children.each do |c|
      next unless Nokogiri::XML::Element === c
      assert_equal 'testcase', c.name
    end
  end

  def test_testcase_passed
    passed = @doc.at_xpath('/testsuite/testcase[@name="test_pass"]')
    assert_equal 0, passed.children.count {|c| Nokogiri::XML::Element === c}
    assert_equal '1', passed['assertions']
  end

  def test_testcase_skipped
    skipped = @doc.at_xpath('/testsuite/testcase[@name="test_skip_assertion"]')
    assert_equal 'skip assertion', skipped.at_xpath('skipped')['message']
    assert_equal '0', skipped['assertions']
  end

  def test_testcase_failures
    failure = @doc.at_xpath('/testsuite/testcase[@name="test_fail_assertion"]')
    assert_equal 'fail assertion', failure.at_xpath('failure')['message']
    assert_equal '1', failure['assertions']
  end

  def test_testcase_errors
    error = @doc.at_xpath('/testsuite/testcase[@name="test_raise_error"]')
    assert_equal 'raise an error', error.at_xpath('failure')['message']
    assert_equal '0', error['assertions']
  end

  def test_testcase_error_with_invalid_chars
    error = @doc.at_xpath('/testsuite/testcase[@name="test_invalid_characters_in_message"]')
    assert_match( /^#<Object/, error.at_xpath('failure')['message'] )
    assert_equal '0', error['assertions']
  end

  def test_testcase_error_with_invalid_name
    error = @doc.at_xpath('/testsuite/testcase[@name="test_invalid_error_name"]')
    assert_match( /^#<Class/, error.at_xpath('failure')['message'] )
    assert_equal '0', error['assertions']
  end

  def test_testcase_error_with_bad_chars
    error = @doc.at_xpath('/testsuite/testcase[@name="test_escaping_failure_message"]')
    msg = "failed: doesn't like single or \"double\" quotes or symbols such as <"
    assert_equal msg, error.at_xpath('failure')['message']
    assert_equal '1', error['assertions']
  end

  def test_output
    output.rewind
    expected = "\ngenerating ci files\n"
    assert_equal expected, output.read
  end

  def test_filtering_backtraces
    error = @doc.at_xpath('/testsuite/testcase[@name="test_raise_error"]')
    refute_match( /lib\/minitest/, error.inner_text )
  end

  def test_testname
    assert File.file?(File.join('test', 'reports',
                      "TEST-spec%2Fwith%3A%3Apunctuation.xml"))
  end
end
