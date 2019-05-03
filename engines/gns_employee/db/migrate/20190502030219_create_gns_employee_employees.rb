class CreateGnsEmployeeEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :gns_employee_employees do |t|
      t.string :code
      t.string :name
      t.string :department
      t.string :position
      t.datetime :starting_date
      t.string :phone
      t.string :mobile
      t.string :email
      t.string :labor_contract_type
      t.string :address
      t.references :country, index: true, references: :gns_area_countries
      t.references :state, index: true, references: :gns_area_states
      t.references :district, index: true, references: :gns_area_districts
      t.string :cache_search
      t.boolean :active, default: true
      
      t.timestamps
    end
  end
end
