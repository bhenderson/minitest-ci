# minitest-ci

* https://github.com/bhenderson/minitest-ci

## Description:

CI reporter plugin for Minitest

This gem was made possible by YP.com

## Features/problems:

* Uses Minitest::Reporter which is only available since version 5

## Synopsis:

  require 'minitest/ci'

Records test results and generates XML files (for junit hudson plugin
for example) at the end of the test run. The report directory is cleaned
between test runs. To disable:

  # test/helper.rb
  Minitest::Ci.clean = false

  # Rakefile (optional, but recommended!)
  task :ci_cleanup do
    require 'minitest/ci'
    Minitest::Ci.new.start
  end
  task :test => %w[ci_cleanup test:one test:two]

## Requirements

* See Rakefile

## Install

    gem install minitest-ci


## Developers

After checking out the source, run:

    $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

## License

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
