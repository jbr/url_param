class Redirect < ActiveRecord::Base
  validates_presence_of :short_url
  self.url_param_column = :short_url
end