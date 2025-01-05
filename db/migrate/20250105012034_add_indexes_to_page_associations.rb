class AddIndexesToPageAssociations < ActiveRecord::Migration[7.1]
  def change
    add_index :page_associations, [:page_id, :tier_list_id], unique: true, where: 'tier_list_id IS NOT NULL'
    add_index :page_associations, [:page_id, :employee_view_id], unique: true, where: 'employee_view_id IS NOT NULL'
  end
end
