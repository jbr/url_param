require File.instance_eval { expand_path join(dirname(__FILE__), 'test_helper') }
require 'active_record'
require 'url_param'

ActiveRecord::Base.send :include, UrlParam

class UrlParamTest < Test::Unit::TestCase
end