if ENV["COVERAGE"] =~ /true|yes|on|1/i
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
  SimpleCov.start do
    add_filter "spec/"
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'brocket'

logpath = File.expand_path("../../tmp/test.log", __FILE__)
require 'fileutils'
FileUtils.mkdir_p(File.dirname(logpath))
BRocket.logger = Logger.new(logpath)

