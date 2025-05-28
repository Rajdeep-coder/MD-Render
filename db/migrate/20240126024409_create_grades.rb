class CreateGrades < ActiveRecord::Migration[7.1]
  def change
    create_table :grades do |t|
      t.string :name
      t.float :rate, default: 0.0
      t.bigint :my_dairy_id
      t.timestamps
    end

    add_column :customers, :rate_type, :integer, default: 0
    add_column :customers, :grade_id, :bigint
    add_column :customers, :chart_id, :bigint

    add_column :buy_milks, :grade_id, :bigint
    add_column :buy_milks, :little_rate, :float

    MyDairy.all.each do |dairy|
      grade = dairy.grades.create(name: 'A', rate: dairy.fate_rate)
      dairy.customers.each do |customer|
        customer.update(grade_id: grade.id)
      end
    end
  end
end
