class InitialScheme < ActiveRecord::Migration
  def self.up
    options = ActiveRecord::Base.connection.adapter_name == 'MySQL' ? 'ENGINE=InnoDB DEFAULT CHARSET=utf8' : nil
    create_table(:bookmarks, :options => options) do |t|
      t.column :url,          :text,     :null => false
      t.column :title,        :text,     :null => false
      t.column :notes,        :text
      t.column :created_at,   :datetime, :null => false
      t.column :updated_at,   :datetime, :null => false
      t.column :lock_version, :integer,  :null => false, :default => 0
    end
  end

  def self.down
    drop_table :bookmarks
  end
end
