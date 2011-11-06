require "minitest/ci"
require "minitest/autorun"
require 'stringio'
require 'nokogiri'

class MockTestSuite < MiniTest::Unit::TestCase
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

class TestMinitest
end

class TestMinitest::TestCi < MiniTest::Unit::TestCase
  @output = StringIO.new
  old_out, MiniTest::Unit.output = MiniTest::Unit.output, @output
  begin
    runner = MiniTest::CiUnit.new

    runner._run_suite MockTestSuite, :test

    @@test_suites.delete MockTestSuite
    MiniTest::Ci.finish runner.output
  ensure
    MiniTest::Unit.output = old_out
  end

  def self.output
    @output
  end

  def setup
    file = "#{MiniTest::Ci.test_dir}/TEST-MockTestSuite.xml"
    assert File.exists?( file ), 'expected xml file to exists'
    @file = File.read file
    @doc = Nokogiri.parse @file
    @doc = @doc.at_xpath('/testsuite')
  end

  def test_testsuite
    assert_equal "1", @doc['skipped']
    assert_equal "2", @doc['failures']
    assert_equal "4", @doc['errors']
    assert_equal "3", @doc['assertions']
    assert_equal "7", @doc['tests']
    assert_equal "MockTestSuite", @doc['name']
  end

  def test_testcase
    assert_equal 7, @doc.children.count {|c| Nokogiri::XML::Element === c}
    @doc.children.each do |c|
      next unless Nokogiri::XML::Element === c
      assert_equal 'testcase', c.name
    end

    passed = @doc.at_xpath('/testsuite/testcase[@name="test_pass"]')
    assert_equal 0, passed.children.count {|c| Nokogiri::XML::Element === c}
    assert_equal '1', passed['assertions']

    skipped = @doc.at_xpath('/testsuite/testcase[@name="test_skip_assertion"]')
    assert_equal 'skip assertion', skipped.at_xpath('skipped')['message']
    assert_equal '0', skipped['assertions']

    failure = @doc.at_xpath('/testsuite/testcase[@name="test_fail_assertion"]')
    assert_equal 'fail assertion', failure.at_xpath('failure')['message']
    assert_equal '1', failure['assertions']

    error = @doc.at_xpath('/testsuite/testcase[@name="test_raise_error"]')
    assert_equal 'raise an error', error.at_xpath('failure')['message']
    assert_equal '0', error['assertions']

    error = @doc.at_xpath('/testsuite/testcase[@name="test_invalid_characters_in_message"]')
    assert_match( /^#<Object/, error.at_xpath('failure')['message'] )
    assert_equal '0', error['assertions']

    error = @doc.at_xpath('/testsuite/testcase[@name="test_invalid_error_name"]')
    assert_match( /^#<Class/, error.at_xpath('failure')['message'] )
    assert_equal '0', error['assertions']

    error = @doc.at_xpath('/testsuite/testcase[@name="test_escaping_failure_message"]')
    msg = "failed: doesn't like single or \"double\" quotes or symbols such as <"
    assert_equal msg, error.at_xpath('failure')['message']
    assert_equal '1', error['assertions']
  end

  def test_output
    self.class.output.rewind
    assert_match( /generating ci files/, self.class.output.read )
  end

  def test_filter_backtrace
    bt = begin; raise; rescue => e; e.backtrace; end

    bt = MiniTest::Ci.send :filter_backtrace, bt

    assert_equal 1, bt.size
    assert_match( /#{__FILE__}/, bt.first )
  end
end
