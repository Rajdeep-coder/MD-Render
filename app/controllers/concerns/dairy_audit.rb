module DairyAudit
	include PdfDownload
	def init_audit
		pdf = init_pdf
		logo_path = Rails.root.join("app/assets/images/logo.png")
		pdf.repeat(:all) do
		  pdf.bounding_box([pdf.bounds.left, pdf.bounds.top + 50], width: pdf.bounds.width, height: 100) do
		    logo_width = 70
		    logo_x = (pdf.bounds.width - logo_width) / 2
		    pdf.image logo_path, width: logo_width, height: 70, at: [logo_x, pdf.bounds.top]
		    pdf.move_down 60
		    pdf.fill_color "28728f"
		    pdf.text "Your Dairy, Our Solution!", size: 12, align: :center
		    pdf.fill_color "000000"
		    pdf.move_down 10
		    pdf.stroke_horizontal_rule
		  end
		end

		pdf.text "#{@current_user.dairy_name}", size: 16, style: :bold, align: :center
		pdf.move_down(5)
		address = @current_user.address
		pdf.text "#{address&.city}, #{address&.state}, #{address&.pin}, #{address&.country}", size: 12, align: :center
		pdf.text "#{t('Date')}: #{params[:from_date]} #{t('to')} #{params[:to_date]}", size: 12, align: :center, style: :bold
		pdf.text "#{@current_user.owner_name} : #{@current_user.phone_number}", size: 12, align: :center
		pdf.move_down(10)
    buy_milks = BuyMilk.joins(customer: :my_dairy).where(my_dairy: { id: @current_user })
    buy_milks = BuyMilk.joins(customer: :my_dairy).where(my_dairy: { id: @current_user })
    date_ranges = split_into_range
    date_ranges.each_with_index do |range, inx|
      table_data_audit(pdf, buy_milks.where(date: range), range)
      if inx != (date_ranges.count - 1)
        pdf.start_new_page
        pdf.move_down(60)
      end
    end

    milk_summary(pdf, buy_milks)
    product_data(pdf)

    pdf.repeat(:all) do
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom - 20], width: pdf.bounds.width, height: 50) do
        pdf.fill_color "2c3e50"
        pdf.text "Contact Us: +916267016717 | Visit our website: www.milkdairy.in", size: 8, align: :center
        pdf.fill_color "000000"
      end
    end
    pdf
	end


	def table_data_audit(pdf, buy_milks, range)
		column_width = pdf.bounds.width / 2 - 5
    column_spacing = 140
    cursor = pdf.cursor
		pdf.bounding_box([pdf.bounds.left + (column_width + column_spacing) * 0, cursor], width: column_width) do
      start_date = range.first
      end_date = range.last
      pdf.text t('Morning Shift'), align: :center, style: :bold
      pdf.move_down(10)
      table_data = [[t('Date'),t('Quantity'), t('Rate'), t('Amount')]]

      while start_date <= end_date && start_date != start_date + 28
        record=buy_milks.where(shift: 'morning', date: start_date)
        add_customer_record_audit(record,table_data,start_date,"morning")
        start_date=start_date+1
      end
      pdf.table(table_data, header: true, width: 264.29, cell_style: { padding: 4, size: 6 })
    end

    pdf.bounding_box([pdf.bounds.left + (column_width + 20) * 1, cursor], width: column_width) do
      start_date = range.first
      end_date = range.last
      pdf.text t('Evening Shift'), align: :center, style: :bold
      pdf.move_down(10)
      table_data = [[t('Quantity'), t('Rate'), t('Amount')]]

      while start_date <= end_date && start_date != start_date + 28
        record=buy_milks.where(shift: 'evening', date: start_date)
        add_customer_record_audit(record,table_data,start_date,"evening")
        start_date=start_date+1
      end
      pdf.table(table_data, header: true, width: 264.29, cell_style: { padding: 4, size: 6 })
    end

    pdf
	end

	def add_customer_record_audit(record, table_data,start_date,shift)
    if record.count > 0  
      if shift == 'morning'
        table_data << [
          record.first['date'].strftime("%d-%m-%Y") || '',
          record.sum(:quntity).round(2) || '',
          (record.sum(:amount) / record.sum(:quntity)).round(2) || '',
          record.sum(:amount).round(2) || '',
        ]
      else
        table_data << [
          record.sum(:quntity).round(2) || '',
          (record.sum(:amount) / record.sum(:quntity)).round(2) || '',
          record.sum(:amount).round(2) || '',
        ]
      end
    else 
      if shift == 'morning'
        table_data << [
              start_date.strftime("%d-%m-%Y") || '','','','']
      else
        table_data << [
              ' ',' ',' ']
      end
    end
  end

  def split_into_range
    from_date = Date.strptime(params[:from_date], "%d-%m-%Y")
    to_date = Date.strptime(params[:to_date], "%d-%m-%Y")

    # Initialize an array to store the ranges
    date_ranges = []

    # First range (28 days)
    current_date = from_date
    first_range_end = [current_date + 27, to_date].min
    date_ranges << (current_date..first_range_end)
    current_date = first_range_end + 1

    # Subsequent ranges (35 days)
    while current_date <= to_date
      range_end = [current_date + 32, to_date].min
      date_ranges << (current_date..range_end)
      current_date = range_end + 1
    end

    date_ranges
  end

  def milk_summary(pdf, buy_milks)
    if pdf.cursor < 95
      pdf.start_new_page
      pdf.move_down(40)
    end
    pdf.move_down(20)
    pdf.text t("Summary"), size: 14, style: :bold, align: :center
    pdf.move_down(10)
    cursor = pdf.cursor
    summary_text = "#{t('Total Amount')}: #{buy_milks.sum(:amount).round(2)}   |   #{t('Total Quantity')}: #{buy_milks.sum(:quntity).round(2)}"
    pdf.text summary_text, size: 12, align: :center
  end

  def product_data(pdf)
    pdf.start_new_page
    pdf.move_down(60)

    column_widths = [200, 100, 100]

    deposit_history = DepositHistory.joins(customer: :my_dairy)
                                     .where(my_dairy: { id: @current_user })
                                     .where(date: params["from_date"].to_date..params["to_date"].to_date)

    products = deposit_history.where(deposit_type: 'product')
    cash = deposit_history.where(deposit_type: 'cash')

    product_data = products.group(:product_id).sum(:quntity)
    product_amounts = products.group(:product_id).sum(:amount)

    table_data = []
    product_data.each do |product_id, quantity|
      product_name = Product.find_by(id: product_id)&.name # Assuming you have a Product model with a name field
      total_amount = product_amounts[product_id]
      table_data << [product_name, quantity.round(2), total_amount.round(2)]
    end

    table_headers = [t("Product Name"), t("Quantity Sold"), t("Total Amount")]

    pdf.text t("Product History"), size: 16, style: :bold, align: :center
    pdf.move_down(20)

    row_height = 20
    table_height = table_data.length * row_height

    if pdf.cursor - table_height < pdf.bounds.bottom
      pdf.start_new_page # If it doesn't fit, start a new page
    end

    table = pdf.table([table_headers] + table_data, column_widths: column_widths, header: true, position: :center) do |table|
      table.row(0).font_style = :bold
      table.rows(1..-1).align = :center
      table.row(0).background_color = 'DDDDDD'
    end

    pdf.move_down(20)

    total_product_quantity = product_data.values.sum
    total_product_amount = product_amounts.values.sum
    total_cash_amount = cash.sum(:amount)

    pdf.text t("Summary"), size: 14, style: :bold, align: :center
    pdf.move_down(10)

    pdf.text "#{t("Total Product Quantity")}: #{total_product_quantity}", size: 12, align: :left
    pdf.text "#{t("Total Product Amount")}: #{total_product_amount.round(2)}", size: 12, align: :left
    pdf.text "#{t("Total Cash Amount")}: #{total_cash_amount.round(2)}", size: 12, align: :left
  end
end
