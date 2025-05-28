module PdfDownload
  include CommonMethod
 def init_pdf
  pdf = Prawn::Document.new(page_size: 'A4', margin: [40, 40, 40, 40], encoding: 'UTF-8')
  pdf.font_families.update("OpenSans" => {
    :normal => Rails.root.join("app/assets/fonts/Kruti.ttf"),
    :italic => Rails.root.join("app/assets/fonts/Kruti.ttf"),
    :bold => Rails.root.join("app/assets/fonts/Kruti.ttf"),
    :bold_italic => Rails.root.join("app/assets/fonts/Kruti.ttf")
    })
  pdf.font "OpenSans"
  pdf
  end

  def customer_info(pdf, data)
    unless params['page'] == "pdf-format"
      dairy_information(pdf,Customer.find_by_id(params[:customer_id]))
      if params[:customer_id].present?
        table_data = [[t('Date'), t('Qty.'), t('Fat'), t('CLR'), t('SNF'), t('Shift'), t('Rate'), t('Amount')]]
      else
        table_data = [['SN.', t('Customer'), t('Date'), t('Qty.'), t('Fat'), t('CLR'), t('SNF'), t('Shift'), t('Rate'), t('Amount')]]
      end
      add_customer_data(data,table_data)
      pdf.table(table_data, header: true, width: 520, cell_style: { padding: 8, size: 10 })
      @filename = data.first.present? ? "##{data.first.customer.sid} #{data.first.customer.name}" : 'NoDataFound'
    else
      customer_ids = data.pluck(:customer_id).uniq
      customer = Customer.where(id: customer_ids).order(sid: :asc)
      customer.each do |obj|

        cursor_1 =pdf.cursor
        dairy_information(pdf,obj)
        final_data = data.where(customer_id: obj.id).order(:shift)

        table_data = [[t('Date'), t('Shift'), t('Qty.'), t('Fat'), t('CLR'), t('SNF'),t('Rate'), t('Amount'), t('Product'), t('Cash')]]
        pdf.move_down(10)
        deposit_history = DepositHistory.where(customer_id: obj.id)
        e_date = params['to_date'].to_date
        add_customer_records(deposit_history,table_data,final_data)
        
        deposit_history = deposit_history.where(date: params["from_date"].to_date..e_date)
        data_total_info(deposit_history,final_data,table_data)

        pdf.table(table_data, header: true, width: 520, cell_style: { padding: 7, size: 8, inline_format: true  })

        deposite_total(pdf,deposit_history,obj.id)
        pdf.start_new_page unless data.pluck(:customer_id).sort.uniq.last == obj.id
      end
    end
  end

  def all_bill(pdf, data)
    pdf.move_down(20)
    customers = @current_user.customers.order(sid: :asc)
    table_data = [['ID', t('Customer'), t('Quantity'), t('Amount'), t("Deposit"), t("Previous"), t("Final")]]
    customers.each do |record|
      table_data << customer_array(record, data)
    end
    pdf.table(table_data, header: true, width: 520, cell_style: { padding: 8, size: 8 })
    @filename = "#{params[:from_date]} to #{params[:to_date]}"
  end

  def customer_array(record, data)
    total_milk_amount = data.where(customer_id: record.id).sum(:amount).round(2) || 0.0
    deposit = DepositHistory.where(customer_id: record.id).where(date: params["from_date"].to_date..params["to_date"].to_date).pluck(:amount).sum.round(2) || 0.0
    deposit_balance = DepositHistory.where(customer_id: record.id).where("date< ?", params[:from_date].to_date).pluck(:amount).sum.round(2) || 0.0
    creadit_balance = BuyMilk.where(customer_id: record.id).where("date < ?",  params[:from_date].to_date ).pluck(:amount).sum.round(2) || 0.0
    previous_amount = (creadit_balance - deposit_balance).round(2)
    [ record.sid,
      record.name,
      data.where(customer_id: record.id).sum(:quntity).round(2) || 0.0,
      total_milk_amount,
      deposit,
      previous_amount,
      (total_milk_amount-deposit+previous_amount).round(2)
    ]
  end

  def summary(pdf, meta, data)
    kg_per_fet = ((meta[:total_quntity].to_f * meta[:fat_avg].to_f) / 100).round(2)
    pdf.move_down(30)
    if pdf.cursor < 100
      pdf.start_new_page
    end
    pdf.text t("Summary"), size: 14, style: :bold, align: :center
    pdf.move_down(20)
    column_width = pdf.bounds.width / 2 - 5
    column_spacing = 140
    cursor = pdf.cursor
      pdf.bounding_box([pdf.bounds.left + (column_width + column_spacing) * 0, cursor], width: column_width) do
        pdf.text t("Average Fat")+": #{meta[:fat_avg]}", size: 12
        pdf.move_down(5)
        pdf.text t("Average CLR")+": #{meta[:clr_avg]}", size: 12
      end

      pdf.bounding_box([pdf.bounds.left + (column_width -60) * 1, cursor], width: column_width) do
        pdf.text t("Average SNF")+": #{meta[:snf_avg]}", size: 12
        pdf.move_down(5)
        pdf.text t("Total Quantity")+": #{meta[:total_quntity]}", size: 12
      end

      pdf.bounding_box([pdf.bounds.left + (column_width -55) * 2, cursor], width: column_width) do
        pdf.text t("Total Amount")+": #{meta[:total_amount]}", size: 12
        pdf.move_down(5)
        pdf.text t("KG/Fat")+" : #{kg_per_fet}", size: 12
      end
  end

  def add_customer_data(data,table_data)
    data.each do |record|
      table_data << 
      unless params[:customer_id].present?
        [
          record.customer.sid,
          record.customer.name,
          record['date'].strftime("%d-%m-%Y"),
          record['quntity'],
          record['fat'],
          record['clr'],
          record['snf'],
          t(record['shift']),
          (record['amount']/record['quntity']).round(2),
          record['amount'],
        ]
      else
        [
          record['date'].strftime("%d-%m-%Y"),
          record['quntity'],
          record['fat'],
          record['clr'],
          record['snf'],
          t(record['shift']),
          (record['amount']/record['quntity']).round(2),
          record['amount'],
        ]
      end
    end
  end

  def add_customer_records(deposit_history,table_data, final_data)
    start_date=params['from_date'].to_date
    e_date = params['to_date'].to_date
    while start_date <= e_date && start_date != e_date+1
      records=final_data.select { |record| record['date'] == start_date }
      deposite_history_cash = deposit_history.where(date: start_date).where(deposit_type: "cash")
      deposite_history_product = deposit_history.where(date: start_date).where(deposit_type: "product")
      if records.present?
        records.each do |record|
          table_data <<
          [
            start_date.strftime("%d-%m-%Y"),
            t(record['shift']),
            record['quntity'],
            record['fat'],
            record['clr'],
            record['snf'],
            (record['amount']/record['quntity']).round(2),
            record['amount'],
            deposite_history_product.present? ? record['shift'] == 'morning' || records.first.shift == "evening" ? deposite_history_product.pluck('amount').sum : " " : " ",
            deposite_history_cash.present? ? record['shift'] == 'morning' || records.first.shift == "evening" ? deposite_history_cash.pluck('amount').sum : " " : " "
          ]
        end
      else
        if deposite_history_product.present? || deposite_history_cash.present?
          table_data <<
            [
                start_date.strftime("%d-%m-%Y"),
                t("morning"),
                " ",
                " ",
                " ",
                " ",
                " ",
                " ",
                deposite_history_product.present? ? deposite_history_product.pluck('amount').sum : " ",
                deposite_history_cash.present? ? deposite_history_cash.pluck('amount').sum : " " 
              ]
        end
      end
      start_date=start_date+1
    end
  end

  def data_total_info(deposit_history,final_data,table_data)
    final_result = record_total(final_data)
    t_deposite_history_cash = deposit_history.where(deposit_type: "cash").pluck(:amount).sum
    t_deposite_history_product = deposit_history.where(deposit_type: "product").pluck(:amount).sum

    table_data << 
      [
        t("Total/Average"),
        " ",
        final_result[:quntity] != 0 ? final_result[:quntity].round(2) : " ",
        final_result[:fat] != 0 ? (final_result[:fat]/final_result[:quntity]).round(2) : " ",
        final_result[:clr] != 0 ? (final_result[:clr]/final_result[:quntity]).round(2) : " ",
        final_result[:snf] != 0 ? (final_result[:snf]/final_result[:quntity]).round(2) : " ",
        final_result[:quntity] != 0 ? (final_result[:amount] / final_result[:quntity]).round(2) : " ",
        final_result[:amount] != 0 ? final_result[:amount].round(2) : " ",
        t_deposite_history_product.round(2) || " ",
        t_deposite_history_cash.round(2) || " " 
      ]
  end
end