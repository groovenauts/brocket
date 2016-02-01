$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'brocket'

logpath = File.expand_path("../../tmp/test.log", __FILE__)
require 'fileutils'
FileUtils.mkdir_p(File.dirname(logpath))
BRocket.logger = Logger.new(logpath)
