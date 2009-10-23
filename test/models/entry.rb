class Entry < ActiveRecord::Base
  validates_presence_of :title
  generate_url_param_from :title
end