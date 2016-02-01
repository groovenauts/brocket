$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'brocket'

BRocket.logger = Logger.new(File.expand_path("../../tmp/test.log", __FILE__))
