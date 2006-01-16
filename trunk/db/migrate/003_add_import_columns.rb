class AddImportColumns < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :hb_eid,      :integer
    add_column :bookmarks, :import_from, :string, :limit => 15
  end

  def self.down
    remove_column :bookmarks, :hb_eid
    remove_column :bookmarks, :import_from
  end
end
