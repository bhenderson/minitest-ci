= minitest-ci

* https://github.com/bhenderson/minitest-ci

== DESCRIPTION:

CI reporter plugin for MiniTest

This gem was made possible by ATT Interactive.

== FEATURES/PROBLEMS:

* Uses MiniTest::Unit#record which is only available since version 2.12.0

== SYNOPSIS:

  require 'minitest/ci'

Records test results and generates XML files (for junit hudson plugin
for example) at the end of the test run. The report directory is cleaned
between test runs. To disable:

  # test/helper.rb
  MiniTest::Ci.disable_clean = true

  # Rakefile (optional, but recommended!)
  task :ci_cleanup do
    require 'minitest/ci'
    MiniTest::Ci.clean
  end
  task :test => %w[ci_cleanup test:one test:two]

== REQUIREMENTS:

* See Rakefile

== INSTALL:

* gem install minitest-ci

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

(The MIT License)

Copyright (c) 2011 bhenderson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
