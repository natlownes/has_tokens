ActiveRecord::Schema.define do
  create_table :messages do |m|
    m.column :name, :string
    m.column :subject, :string
    m.column :body, :text
    m.column :sender, :string
    m.column :receiver, :string
  end
end