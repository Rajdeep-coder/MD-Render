ActiveAdmin.register_page "Upload Chart Rates" do
  menu parent: "MyDairy Management", priority: 1

  content title: "Upload Chart Rates" do
    para "Select a dairy, chart type (CLR or SNF), and upload a CSV file to update rates.", class: "page-description"

    para do
      link_to "Download Sample CSV File", "/sample_chart_rates.csv", target: "_blank", class: "download-link"
    end

    active_admin_form_for :chart_rates_upload, url: admin_chart_rates_upload_path, method: :post, html: { class: 'chart-rates-upload-form' } do |f| 
      div class: "form-group" do
        f.input :my_dairy_id, as: :searchable_select, 
                              collection: MyDairy.select("CONCAT(dairy_name, ' ', '(', phone_number, ')') AS dairy_name, id")
                                                .to_a
                                                .pluck(:dairy_name, :id),
                              label: "Select Dairy", 
                              input_html: { class: 'my-dairy-select', style: 'width: 100%;' }
      end

      div class: "form-group" do
        f.input :chart_id, as: :select, 
                           collection: [], 
                           label: "Select Chart", 
                           input_html: { class: 'chart-select', disabled: true, style: 'width: 100%;' }
      end

      div class: "form-group" do
        f.input :chart_type, as: :select, collection: ["CLR", "SNF"], label: "Select Chart Type", 
                             input_html: { style: 'width: 100%;' }
      end

      div class: "form-group" do
        f.input :csv_file, as: :file, label: "Upload CSV File", 
                           input_html: { style: 'width: 100%; padding: 8px;', accept: '.csv' }
      end

      div class: "form-actions" do
        f.actions do
          f.action :submit, label: "Upload Rates", wrapper_html: { class: 'submit-button-wrapper' }
        end
      end
    end
  end
end
