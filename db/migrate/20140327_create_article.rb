class CreateArticle < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title
      t.text :description
      t.string :feeling
      t.string :locale
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
