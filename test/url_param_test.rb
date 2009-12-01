require File.instance_eval { expand_path join(dirname(__FILE__), 'test_helper') }
require 'active_record'
require 'url_param'

class UrlParamTest < Test::Unit::TestCase
  context 'with an entry' do
    should 'have the expected url param mappings' do
      {
        'hello world' => 'hello-world',
        '  hello 1234 ' => 'hello-1234',
        '--------hello!@#$%@--world' => 'hello-world',
        'HELLO WORLD' => 'hello-world'
      }.each do |title, url_param|
        entry = Entry.new :title => title
        assert_url_param url_param, entry
        assert_to_param url_param, entry
      end
    end
    
    should 'clear errors on the url param column if the source column has errors' do
      entry = Entry.new
      assert_not_valid entry
      assert_not_nil entry.errors.on(:title)
      assert_nil entry.errors.on(:url_param)
    end
  end
  
  context 'with a saved entry' do
    setup {@entry = Entry.create :title => 'hello world'}

    should 'generate a unique url param for a new record with an identical title' do
      assert_url_param 'hello-world-1', Entry.new(:title => 'hello world')
    end
    
    should 'progressively generate incremented url params' do
      Entry.create :title => 'hello world'
      assert_url_param 'hello-world-2', Entry.new(:title => 'hello world')
    end

    should 'find the record by url param' do
      assert_equal @entry, Entry.find_by_param('hello-world')
    end
    
    should 'find the record by url param with the bracket operator' do
      assert_equal @entry, Entry['hello-world']
    end
    
    should 'update the url param when the title changes teardown save' do
      @entry.title = 'howdy world'
      assert_url_param 'hello-world', @entry
      
      @entry.save
      assert_url_param 'howdy-world', @entry
    end
    
    should 'validate format of url param' do
      @entry.url_param = "only hyphens, numbers, and lowercase Letters are allowed"
      assert_not_valid @entry
      assert_not_nil @entry.errors.on(:url_param)
    end
    
    should 'validate uniqueness of url param' do
      @new_entry = Entry.new :title => 'foo', :url_param => 'hello-world'
      assert_not_valid @new_entry
      assert_full_messages ['Url param has already been taken'], @new_entry.errors
    end
    
    teardown {Entry.destroy_all}
  end
  
  context 'using find by param on a model that sets a url param column but does not generate url param' do
    setup {@redirect = Redirect.create :short_url => 'abcde'}
    
    should 'find by url param column' do
      assert_equal @redirect, Redirect.find_by_param('abcde')
    end
    
    should 'work with the bracket method too' do
      assert_equal @redirect, Redirect['abcde']
    end
    
    should 'have the right to param' do
      assert_to_param 'abcde', @redirect
    end
    
    teardown {Redirect.destroy_all}
  end
  
  context 'using find by param on a model that does nothing related to url param' do
    setup {@user = User.create :name => 'joe'}

    should 'find by id' do
      assert_equal @user, User.find_by_param(@user.id)
    end
    
    should 'output id as to param' do
      assert_to_param @user.id.to_s, @user
    end
    
    teardown {User.destroy_all}
  end
  
end