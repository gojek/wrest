class CreateBottle < ActiveRecord::Migration
  def self.up
    create_table :bottles do |t|
        t.string :type
        t.string :name
        t.integer :universe_id
    end
  end

  def self.down
    drop_table  :bottles
  end
end
