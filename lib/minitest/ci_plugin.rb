require 'minitest/ci'

module Minitest

  def self.plugin_ci_init options
    self.reporter << Ci.new(options[:io], options)
  end

  def self.plugin_ci_options opts, options
    opts.on "--ci-dir", "Set the CI report dir. Default to #{Ci.report_dir}" do |dir|
      options[:ci_dir] = dir
    end

    opts.on "--[no-]ci-clean", "Clean the CI report dir in between test runs. Default #{Ci.clean}" do |clean|
      options[:ci_clean] = clean
    end
  end

end
