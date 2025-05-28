class ChartRate < ApplicationRecord
  self.table_name = :chart_rates
  belongs_to :chart
end
