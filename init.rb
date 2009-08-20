ActiveRecord::Base.send :include, UrlParam

if defined?(ResourcefulLoader)
  ResourcefulLoader.default_finder = :find_by_param
end
