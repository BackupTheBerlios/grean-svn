class AddActsAsTaggableTables < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string, :limit => 255, :null => false
    end
    add_index :tags, :name, :unique => true

    create_table :tags_bookmarks do |t|
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
