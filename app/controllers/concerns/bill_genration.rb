module BillGenration
  include CommonMethod
	def init_pdf
		pdf = Prawn::Document.new(page_size: 'A4', margin: [40, 40, 40, 40])
    pdf.font_families.update("OpenSans" => {
      :normal => Rails.root.join("app/assets/fonts/siddhanta.ttf"),
      :italic => Rails.root.join("app/assets/fonts/siddhanta.ttf"),
      :bold => Rails.root.join("app/assets/fonts/siddhanta.ttf"),
      :bold_italic => Rails.root.join("app/assets/fonts/siddhanta.ttf")
    })

    pdf.font("OpenSans")
    pdf
	end

  def customer_info_one(pdf, data, meta)
    customer_ids = data.pluck(:customer_id).uniq
    customer = Customer.where(id: customer_ids).order(sid: :asc)
    customer.each do |obj|
      cursor_1 =pdf.cursor
      dairy_information(pdf,obj)
      final_data = data.where(customer_id: obj.id)
      column_width = pdf.bounds.width / 2 - 5
      column_spacing = 140
      cursor = pdf.cursor

      pdf.bounding_box([pdf.bounds.left + (column_width + column_spacing) * 0, cursor], width: column_width) do
        pdf.text t('Morning Shift'), align: :center, style: :bold
        pdf.move_down(10)
        table_data = [[t('Date'),t('Quantity'), t('Fat'), t('CLR'), t('SNF'), t('Rate'), t('Amount')]]
        start_date=params['from_date'].to_date

        while start_date <= params['to_date'].to_date && start_date != params['from_date'].to_date + 28
          record=final_data.select { |record| record['shift'] == 'morning' && record['date'] == start_date }
          add_customer_record(record,table_data,start_date,"morning")
          start_date=start_date+1
        end
        pdf.table(table_data, header: true, width: 264.29, cell_style: { padding: 4, size: 6 })
      end

      pdf.bounding_box([pdf.bounds.left + (column_width + 20) * 1, cursor], width: column_width) do
        pdf.text t('Evening Shift'), align: :center, style: :bold
        pdf.move_down(10)
        table_data = [[t('Quantity'), t('Fat'), t('CLR'), t('SNF'), t('Rate'), t('Amount')]]
        start_date=params['from_date'].to_date

        while start_date <= params['to_date'].to_date && start_date != params['from_date'].to_date + 28
          record=final_data.select { |record| record['shift'] == 'evening' && record['date'] == start_date }
          add_customer_record(record,table_data,start_date,"evening")
          start_date=start_date+1
        end
        pdf.table(table_data, header: true, width: 264.29, cell_style: { padding: 4, size: 6 })
      end

      unless params['from_date'].to_date + 27 > params['to_date'].to_date
        pdf.start_new_page

        pdf.bounding_box([pdf.bounds.left + (column_width + column_spacing) * 0, cursor_1], width: column_width) do
          table_data = [[t('Date'),t('Quantity'), t('Fat'), t('CLR'), t('SNF'), t('Rate'), t('Amount')]]
          start_date=params['from_date'].to_date + 28
          while start_date <= params['to_date'].to_date && start_date != params['from_date'].to_date + 27
            record=final_data.select { |record| record['shift'] == 'morning' && record['date'] == start_date }
            add_customer_record(record,table_data,start_date,"morning")
            start_date=start_date+1
          end
          pdf.table(table_data, header: true, width: 264.29, cell_style: { padding: 4, size: 6 })
        end

        pdf.bounding_box([pdf.bounds.left + (column_width + 20) * 1, cursor_1], width: column_width) do
          table_data = [[t('Quantity'), t('Fat'), t('CLR'), t('SNF'), t('Rate'), t('Amount')]]
          start_date=params['from_date'].to_date + 28
          while start_date <= params['to_date'].to_date && start_date != params['from_date'].to_date + 27
            record=final_data.select { |record| record['shift'] == 'evening' && record['date'] == start_date }
            add_customer_record(record,table_data,start_date,"evening")
            start_date=start_date+1
          end
          pdf.table(table_data, header: true, width: 264.29, cell_style: { padding: 4, size: 6 })
        end
      end

      cursor = pdf.cursor
      pdf.bounding_box([pdf.bounds.left + (column_width + column_spacing) * 0, cursor], width: column_width) do
        pdf.move_down(10)
        morning_data = final_data.select { |record| record['shift'] == 'morning' }
        meta_data = add_customer_meta(morning_data,"morning")
        pdf.table(meta_data, width: 264.29, cell_style: { padding: 4, size: 6 })
      end

      pdf.bounding_box([pdf.bounds.left + (column_width + 20) * 1, cursor], width: column_width) do
        pdf.move_down(10)
        evening_data = final_data.select { |record| record['shift'] == 'evening' }
        meta_data = add_customer_meta(evening_data,"evening")
        pdf.table(meta_data, width: 264.29, cell_style: { padding: 4, size: 6 })
      end
      
      pdf.move_down(10)
      customer_summary(pdf,final_data, params['to_date'].to_date - params['from_date'].to_date )
      @filename = "##{obj.sid} #{obj.name}"
      pdf.start_new_page unless data.pluck(:customer_id).sort.uniq.last == obj.id

    end
  end


  def customer_summary(pdf, data,record_count)
    summary_text(pdf,data)
    final_count_2 = nil
    customer_id = data.pluck(:customer_id).uniq.first

    deposit_history = DepositHistory.where(customer_id: customer_id).where(date: params["from_date"].to_date..params["to_date"].to_date).order(:date)
    final_count = deposit_history.count
    final_data_1, final_data_2 = final_product_data(deposit_history,record_count,final_count)
    final_count_1 = final_data_1.count
    final_count_2 = final_data_2.count
    pdf.move_down(3)
    column_width = pdf.bounds.width / 2 - 5
    column_spacing = 140

    if final_data_1.present?
      pdf.move_down(10)
      pdf.text t("Deposit History"), size: 16, style: :bold, align: :center
      pdf.move_down(10)
      table_data_1,table_data_2 = add_product_record(final_data_1,final_data_2,final_count_2,final_count_1)
      
      cursor = pdf.cursor
      pdf.bounding_box([pdf.bounds.left + (column_width + column_spacing) * 0, cursor], width: column_width) do
        pdf.table(table_data_1, header: true, width: 250, position: :center, cell_style: { padding: 4, size: 6 })
      end

      pdf.bounding_box([pdf.bounds.left + (column_width + 20) * 1, cursor], width: column_width) do
        pdf.table(table_data_2, header: true, width: 250, position: :center, cell_style: { padding: 4, size: 6 })
      end
    end

    unless final_count == final_count_1 + final_count_2
      pdf.start_new_page
      remaining_record = final_count - (final_count_1 + final_count_2)
      first_tab = nil
      second_tab = nil
      if remaining_record.odd?
        first_tab = (remaining_record/2).ceil+1
        second_tab = remaining_record - first_tab
      else
        first_tab = (remaining_record/2).ceil
        second_tab = remaining_record - first_tab
      end

      final_data_1 = deposit_history.offset(final_count_1 + final_count_2).limit(first_tab)
      final_count_3 = final_data_1.count
      final_data_2 = deposit_history.offset(final_count_1 + final_count_2 + first_tab)
      final_count_4 = final_data_2.count

      table_data_1,table_data_2 = add_product_record(final_data_1,final_data_2,final_count_4,final_count_3)
      cursor = pdf.cursor

      pdf.bounding_box([pdf.bounds.left + (column_width + column_spacing) * 0, cursor], width: column_width) do
        pdf.table(table_data_1, header: true, width: 250, position: :center, cell_style: { padding: 4, size: 6 })
      end

      pdf.bounding_box([pdf.bounds.left + (column_width + 20) * 1, cursor], width: column_width) do
        pdf.table(table_data_2, header: true, width: 250, position: :center, cell_style: { padding: 4, size: 6 })
      end

    end 
    deposite_total(pdf, deposit_history, customer_id)
  end

  def final_product_data(deposit_history,record_count,final_count)
    final_data_1 = nil
    final_data_2 = nil
    case record_count.to_i
      when 10 || 11 || 12
          final_data_1,final_data_2 = final_data(deposit_history,8,final_count)
      when 13
          final_data_1,final_data_2 = final_data(deposit_history,7,final_count)
      when 14
          final_data_1,final_data_2 = final_data(deposit_history,6,final_count)
      when 15
          final_data_1,final_data_2 = final_data(deposit_history,5,final_count)
      when 16
          final_data_1,final_data_2 = final_data(deposit_history,4,final_count)
      when 17
          final_data_1,final_data_2 = final_data(deposit_history,3,final_count)
      when 18
          final_data_1,final_data_2 = final_data(deposit_history,2,final_count)
      when 19
          final_data_1,final_data_2 = final_data(deposit_history,1,final_count)
      else
        final_data_1,final_data_2 = final_data(deposit_history)
      end
      [final_data_1,final_data_2]
  end

  def final_data(deposit_history,count = nil,final_count = nil)
    if count.present? && final_count > count * 2
      final_data_1 = deposit_history.limit(count)
      final_data_2 = deposit_history.offset(count).limit(count)
      [final_data_1,final_data_2]
    else
      # final_data_1,final_data_2 = final_data(deposit_history)
      record_count = ((deposit_history.count)/2).ceil
      if (deposit_history.count).odd?
        final_data_1 = deposit_history.limit(record_count+1)
        final_data_2 = deposit_history.offset(record_count+1)
        [final_data_1,final_data_2]
      else
        final_data_1 = deposit_history.limit(record_count)
        final_data_2 = deposit_history.offset(record_count)
        [final_data_1,final_data_2]
      end
    end
  end

  def add_customer_record(record, table_data,start_date,shift)
    unless record.count == 0
              
      if record.count == 1
        
        record=record.first
        unless shift == 'evening'
          table_data << [
            record['date'].strftime("%d-%m-%Y") || '',
            record['quntity'].round(2) || '',
            record['fat']&.round(2) || '',
            record['clr']&.round(2) || '',
            record['snf']&.round(2) || '',
            (record.amount / record.quntity).round(2) || '',
            record['amount'].round(2) || '',
          ]
        else
          table_data << [
            record['quntity'].round(2) || '',
            record['fat']&.round(2) || '',
            record['clr']&.round(2) || '',
            record['snf']&.round(2) || '',
            (record.amount / record.quntity).round(2) || '',
            record['amount'].round(2) || '',
          ]
        end
      else
        
        arr = Array.new 5,0.0
        
        record.each do |record1|
          arr[0] += record1['quntity']
          arr[1] += (record1['fat'] * record1['quntity'])
          arr[2] += record1['clr'] ? (record1['clr'] * record1['quntity']) : 0
          arr[3] += record1['snf'] ? (record1['snf'] * record1['quntity']) : 0
          arr[4] += record1['amount']
        end

        unless shift == 'evening'
          table_data << [
          record[0]['date'].strftime("%d-%m-%Y") || '',
            arr[0].round(2) || '',
            (arr[1]/arr[0]).round(2) || '',
            (arr[2]/arr[0]).round(2) || '',
            (arr[3]/arr[0]).round(2) || '',
            (arr[4] / arr[0]).round(2) || '',
            arr[4].round(2) || '',
          ]
        else
          table_data << [
            arr[0].round(2) || '',
            (arr[1]/arr[0]).round(2) || '',
            (arr[2]/arr[0]).round(2) || '',
            (arr[3]/arr[0]).round(2) || '',
            (arr[4] / arr[0]).round(2) || '',
            arr[4].round(2) || '',
          ]
        end
      end

    else 
      unless shift == 'evening'
        table_data << [
              start_date.strftime("%d-%m-%Y") || ' ','','','','','','']
      else
        table_data << [
              ' ',' ',' ',' ',' ',' ']
      end

    end
  end

  def add_customer_meta(data,shift)
    final_result = record_total(data)
    unless shift == 'evening'
      meta_data = [[
                t('Total/Average'), 
                final_result[:quntity] != 0 ? final_result[:quntity].round(2) : " ", 
                final_result[:fat] != 0 ? (final_result[:fat]/final_result[:quntity]).round(2) : " ", 
                final_result[:clr] != 0 ? (final_result[:clr]/final_result[:quntity]).round(2) : " ", 
                final_result[:snf] != 0 ? (final_result[:snf]/final_result[:quntity]).round(2) : " ", 
                final_result[:quntity] != 0 ? (final_result[:amount]/final_result[:quntity]).round(2) : " " , 
                final_result[:amount] != 0 ? final_result[:amount].round(2) : " " 
              ]] 
    else
      meta_data = [[ 
                final_result[:quntity] != 0 ? final_result[:quntity].round(2) : " ", 
                final_result[:fat] != 0 ? (final_result[:fat]/final_result[:quntity]).round(2) : " ", 
                final_result[:clr] != 0 ? (final_result[:clr]/final_result[:quntity]).round(2) : " ", 
                final_result[:snf] != 0 ? (final_result[:snf]/final_result[:quntity]).round(2) : " ", 
                final_result[:quntity] != 0 ? (final_result[:amount]/final_result[:quntity]).round(2) : " " , 
                final_result[:amount] != 0 ? final_result[:amount].round(2) : " " 
              ]] 
    end
  end

  def add_product_record(final_data_1,final_data_2,final_count_1,final_count_2)
    table_data_1 = [[t('Date'), t('Type'), t('Amount')]]
    table_data_2 = [[t('Date'), t('Type'), t('Amount')]]

    final_data_1&.each do |data|
      table_data_1 << [
        data.date.strftime('%d-%m-%Y'),
        data.product_id == nil ? data.deposit_type: Product.find_by_id(data.product_id)&.name,
        data.amount
      ]
    end
    final_data_2&.each do |data|
        table_data_2 << [
          data.date.strftime('%d-%m-%Y'),
          data.product_id == nil ? data.deposit_type: Product.find_by_id(data.product_id)&.name,
          data.amount
        ]
    end
    unless final_count_1 == final_count_2
      for i in 1..(final_count_2-final_count_1)
        table_data_2 << [
          ' ',
          ' ',
          ' '
        ]
      end
    end
    [table_data_1,table_data_2]
  end

  def summary_text(pdf,data)
    final_result = record_total(data)
    pdf.move_down(5)
    summary_text = t("Average Fat")+": #{final_result[:fat] != 0 ? (final_result[:fat]/final_result[:quntity]).round(2) : " "}, " 
    summary_text+=t("Average CLR")+": #{final_result[:clr] != 0 ? (final_result[:clr]/final_result[:quntity]).round(2) : " "}, "
    summary_text+=t("Average SNF")+": #{final_result[:snf] != 0 ? (final_result[:snf]/final_result[:quntity]).round(2) : " "}, "
    summary_text+=t("Total Quantity")+": #{final_result[:quntity] != 0 ? final_result[:quntity].round(2) : " "}, "
    summary_text+=t("Total Amount")+": #{final_result[:amount] != 0 ? final_result[:amount].round(2) : " "}, "
    summary_text+=t("Rate")+": #{final_result[:quntity] != 0 ? (final_result[:amount] / final_result[:quntity]).round(2) : " "} "

    pdf.move_down(5)
    pdf.table([[summary_text]], header: false, width: pdf.bounds.width, cell_style: { padding: 7, size: 7, :border_lines => [:dashed, :dashed, :dashed, :dashed] }) do
      cells.columns(0).style(font_style: :bold, inline_format: true)
    end
  end

end
