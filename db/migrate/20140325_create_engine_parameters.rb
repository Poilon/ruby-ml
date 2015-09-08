class CreateEngineParameters < ActiveRecord::Migration
  def self.up
    create_table :engine_parameters do |t|
      t.hstore :data
      t.string :name
      t.integer :version
      t.timestamps
    end
  end

  def self.down
    drop_table :engine_parameters
  end
end
