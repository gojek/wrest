class CreateOogas < ActiveRecord::Migration
  def self.up
    create_table :oogas do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :oogas
  end
end
