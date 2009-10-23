require 'rubygems'
dirname = File.dirname(__FILE__)
$:.unshift File.instance_eval { expand_path join(dirname, "..", "lib") }

ENV['RAILS_ENV'] = RAILS_ENV = 'test'

require 'test/unit'
require 'test_rig'
require 'context'
require 'activerecord'

config = YAML::load(IO.read(dirname + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection config['test']

load(dirname + "/schema.rb")

require 'url_param'
require File.expand_path(dirname + '/../init.rb')

Dir[dirname + '/models/*'].each {|model| require model}

  
class Test::Unit::TestCase
  include TestRig
end

