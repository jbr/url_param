ActiveRecord::Schema.define :version => 0 do
  create_table :entries, :force => true do |t|
    t.column :title, :string
    t.column :url_param, :string
  end
  
  create_table :redirects, :force => true do |t|
    t.column :short_url, :string
  end
  
  create_table :users, :force => true do |t|
    t.column :name, :string
  end
end