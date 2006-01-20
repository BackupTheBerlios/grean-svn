class AddActsAsTaggableTables < ActiveRecord::Migration
  def self.up
    options = ActiveRecord::Base.connection.adapter_name == 'MySQL' ? 'ENGINE=InnoDB DEFAULT CHARSET=utf8' : nil
    create_table(:tags, :options => options) do |t|
      t.column :name, :string, :limit => 255, :null => false
    end
    add_index :tags, :name, :unique => true

    create_table(:tags_bookmarks, :options => options) do |t|
      t.column :bookmark_id, :integer, :null => false
      t.column :tag_id,      :integer, :null => false
    end
    remove_column :tags_bookmarks, :id # 重要
  end

  def self.down
    drop_table :tags
    drop_table :tags_bookmarks
  end
end
