class AddTermRelationshipsBanners < ActiveRecord::Migration
  def up
  	create_table :term_relationships_banners do |t|
      
  		t.integer :banner_id, :limit => 100
  		t.integer :term_id, :limit => 11
  		t.timestamps

  	end
  end

  def down
  	drop_table :term_relationships_banners
  end
end