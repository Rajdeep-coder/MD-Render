module Admin
  class CustomAdminController < ApplicationController
    before_action :authenticate_admin_user!

    def charts_by_dairy
      my_dairy = MyDairy.find(params[:id])
      charts = my_dairy.charts.pluck(:name, :id)
      render json: charts.map { |name, id| { id: id, name: name } }
    end

    def upload_chart_rates
      chart_id = params[:chart_rates_upload][:chart_id]
      chart_type = params[:chart_rates_upload][:chart_type]
      csv_file = params[:chart_rates_upload][:csv_file]

      if chart_id.blank? || chart_type.blank? || csv_file.blank?
        redirect_to admin_upload_chart_rates_path, alert: "All fields are required."
        return
      end

      chart = Chart.find(chart_id)

      begin
        if chart_type == "CLR"
          ChartRatesService::ClrService.new(chart, csv_file).update_rates
        elsif chart_type == "SNF"
          ChartRatesService::SnfService.new(chart, csv_file).update_rates
        else
          redirect_to admin_upload_chart_rates_path, alert: "Invalid chart type selected."
          return
        end

        redirect_to admin_upload_chart_rates_path, notice: "#{chart_type} rates updated successfully."
      rescue => e
        redirect_to admin_upload_chart_rates_path, alert: "Error processing file: #{e.message}"
      end
    end
  end
end
