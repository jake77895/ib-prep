class CreateCompanyTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :company_types do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
