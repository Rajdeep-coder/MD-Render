# app/services/chart_rates_service/snf_service.rb
module ChartRatesService
  class SnfService
    def initialize(chart, csv_file)
      @chart = chart
      @csv_file = csv_file
    end

    def update_rates
      data = CSV.read(@csv_file.path)
      fats = data[0][1..]

      data[1..].each do |row|
        snf = row[0]
        rates = row[1..]
        
        fats.each_with_index do |fat, index|
          chart_rate = @chart.chart_rates.find_or_create_by(fat: fat, snf: snf)
          clr = caculate_clr(snf, fat).round
          chart_rate.update(rate: rates[index], clr: clr) if chart_rate
        end
      end
    end

    def caculate_clr(snf, fat)
      (snf - (0.21 * fat) - 0.66) * 4
    end
  end
end
