class CreateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :templates do |t|
      t.string :name, null: false
      t.integer :purpose, null: false
      t.string :default_provider, null: false
      t.string :external_template_id
      t.string :subject
      t.text :html_body
      t.text :text_body
      t.jsonb :merge_schema, default: {}
      t.jsonb :meta, default: {}

      t.timestamps
    end
    
    add_index :templates, :purpose
    add_index :templates, :default_provider
  end
end
