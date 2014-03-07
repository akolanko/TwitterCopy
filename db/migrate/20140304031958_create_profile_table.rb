class CreateProfileTable < ActiveRecord::Migration
  def change
  	create_table :profiles do |t|
  		t.string :location
  		t.string :website
  		t.integer :user_id
  	end
  end
end
