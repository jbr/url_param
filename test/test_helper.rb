dirname = File.dirname(__FILE__)

begin
  require File.instance_eval { expand_path join(dirname, '..', 'vendor', 'gems', 'environment')}
  Bundler.require_env :test
rescue LoadError
  puts "Bundling Gems\n\nHang in there, this only has to happen once...\n\n"
  system 'gem bundle'
  retry
end

$:.unshift File.instance_eval { expand_path join(dirname, "..", "lib") }

ENV['RAILS_ENV'] = RAILS_ENV = 'test'

require 'test/unit'

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

