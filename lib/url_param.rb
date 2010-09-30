module UrlParam
  def self.included(klass)
    klass.extend ClassMethods
    klass.url_param_column = :id
  end
  
  protected

  def generate_url_param
    value = send(self.class.url_param_generation_column).to_s.
      downcase.gsub(/[^a-z0-9]/, "-").squeeze("-").gsub(/^-|-$/, '')
    scope = new_record? ? self.class : self.class.scoped(:conditions => ['id != ?', self.id])
    while scope.scoped(:conditions => ['url_param = ?', value]).count > 0
      value += '-0' unless value =~ /-[0-9]+$/
      value.gsub!(/([0-9]+)$/){ $1.to_i + 1 }
    end
    value.squeeze("-").gsub /-$/, ''
  end
  
  
  def set_url_param
    if url_param.blank? || send(:"#{self.class.url_param_generation_column}_changed?")
      self[:url_param] = generate_url_param unless url_param_changed? && !self[:url_param].blank?
    end
  end
  
  def clear_url_param_errors_if_column_has_errors
    errors.clear_on :url_param if errors.on self.class.url_param_generation_column
  end
  

  module ClassMethods
    attr_accessor :url_param_generation_column
    
    def url_param_column
      @url_param_column || :id
    end
    
    def url_param_column=(upc)
      @url_param_column = upc.to_sym
      self.send(:define_method, :to_param) do
        send(self.class.url_param_column).to_s
      end
    end

    def find_by_param(*args)
      send :"find_by_#{url_param_column}", *args
    end
    alias_method :[], :find_by_param

    def find_by_param!(*args)
      send :"find_by_#{url_param_column}!", *args
    end
    
    def generate_url_param_from(column_name)
      self.url_param_generation_column = column_name
      before_validation :set_url_param
      validates_uniqueness_of :url_param
      validates_presence_of :url_param
      validates_format_of :url_param, :with => /^[a-z0-9-]+$/
      after_validation :clear_url_param_errors_if_column_has_errors
      self.send(:define_method, :url_param) {self[:url_param] ||= self.generate_url_param}
      self.url_param_column = :url_param
    end
  end
end

module ActiveRecord
  class Errors
    def clear_on(attribute)
      @errors.delete attribute.to_s
    end
  end
end
