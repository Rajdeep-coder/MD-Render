class CreateSubcriptionPlan < ActiveRecord::Migration[7.1]
  def change
    Plan.create(name: "Free Trail", validity: 30, amount: 0)
    Plan.create(name: "1 Month", validity: 30, amount: 99)
    Plan.create(name: "3 Months", validity: 90, amount: 249)
    Plan.create(name: "6 Months", validity: 180, amount: 499)
    Plan.create(name: "1 Year", validity: 365, amount: 999)
    Plan.create(name: "5 Years", validity: 1825, amount: 3999)
  end
end
