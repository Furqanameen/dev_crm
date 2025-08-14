class UpdateProvidersSchema < ActiveRecord::Migration[8.0]
  def up
    # Change name from integer to string
    change_column :providers, :name, :string, null: false
    
    # Add status column as integer enum
    add_column :providers, :status, :integer, default: 0, null: false
    
    # Add description column
    add_column :providers, :description, :text
    
    # Add configuration column (JSONB)
    add_column :providers, :configuration, :jsonb, default: {}
    
    # Remove old columns that are no longer needed
    remove_column :providers, :credentials, :text
    remove_column :providers, :settings, :jsonb
    remove_column :providers, :active, :boolean
    
    # Add new indexes
    add_index :providers, :status
    remove_index :providers, :active if index_exists?(:providers, :active)
  end
  
  def down
    # Reverse the changes
    change_column :providers, :name, :integer, null: false
    
    remove_column :providers, :status, :integer
    remove_column :providers, :description, :text
    remove_column :providers, :configuration, :jsonb
    
    add_column :providers, :credentials, :text
    add_column :providers, :settings, :jsonb, default: {}
    add_column :providers, :active, :boolean, default: true
    
    remove_index :providers, :status if index_exists?(:providers, :status)
    add_index :providers, :active
  end
end
