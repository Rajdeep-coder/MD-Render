module ChartRatesService
  class ClrService
    def initialize(chart, csv_file)
      @chart = chart
      @csv_file = csv_file
    end

    def update_rates
      data = CSV.read(@csv_file.path)
      fats = data[0][1..]

      data[1..].each do |row|
        clr = row[0]
        rates = row[1..]
        
        fats.each_with_index do |fat, index|
          chart_rate = @chart.chart_rates.find_or_create_by(fat: fat, clr: clr)
          snf = caculate_snf(clr.to_f, fat.to_f).round(2)
          chart_rate.update(rate: rates[index], snf: snf) if chart_rate
        end
      end
    end

    def caculate_snf(clr, fat)
      (clr/4) + (0.21 * fat) + 0.66
    end
  end
end
