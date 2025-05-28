module CommonMethod
	def dairy_information(pdf,obj)
    pdf.text "#{@current_user.dairy_name}", size: 16, style: :bold, align: :center
    pdf.move_down(5)
    address = @current_user.address
    pdf.text "#{address&.city}, #{address&.state}, #{address&.pin}, #{address&.country}", size: 12, align: :center
    pdf.text "#{@current_user.owner_name} : #{@current_user.phone_number}", size: 12, align: :center
    pdf.move_down(10)
    pdf.text t("Date")+": #{params[:from_date]} "+t("to")+" #{params[:to_date]}", size: 14, align: :center
    if obj.present?
    	pdf.text "##{obj.sid} #{obj.name} - #{obj.phone_number}", size: 14, style: :bold, align: :center
  	end
    pdf.move_down(10)
  end

  def record_total(data)
    final_data = data.pluck('quntity','fat','clr','snf','amount')
    final_total = Hash.new
    final_total[:quntity] = 0
    final_total[:fat] = 0
    final_total[:clr] = 0
    final_total[:snf] = 0
    final_total[:amount] = 0
    final_total[:kg_fat] = 0
    final_data.each do |record|
      final_total[:quntity] += record[0]
      final_total[:fat] += record[1] * record[0]
      final_total[:clr] += record[2] * record[0] unless record[2] == nil
      final_total[:snf] += record[3] * record[0] unless record[3] == nil
      final_total[:amount] += record[4]
      final_total[:kg_fat] += ((record[0] * record[1])/100)
    end
    final_total
  end

  def deposite_total(pdf,deposit_history, id)
  		product_cash = deposit_history.where(deposit_type: "product").pluck(:amount).sum.round(2)
      cash_amount = deposit_history.where(deposit_type: "cash").pluck(:amount).sum.round(2)
      total_milk_amount = BuyMilk.where(customer_id: id).where(date: params["from_date"].to_date..params["to_date"].to_date).pluck(:amount).sum.round(2)
      deposit_balance = DepositHistory.where(customer_id: id).where("date< ?", params[:from_date].to_date).pluck(:amount).sum
      creadit_balance = BuyMilk.where(customer_id: id).where("date < ?",  params[:from_date].to_date ).pluck(:amount).sum
      previous_amount = (creadit_balance - deposit_balance).round(2)
      
      pdf.move_down(20)
      pdf.text t("Total Cash")+" : #{cash_amount} ", size: 10, style: :bold, align: :left
      pdf.move_down(-20)
      pdf.text t("Total Product Cash")+" : #{product_cash} ",size: 10, style: :bold, align: :right
      pdf.move_down(10)
      total = (total_milk_amount-cash_amount-product_cash+previous_amount).round(2)
      msg = total.positive? ? t("To give to the party") : t("Take from the party")
      table_data =[
      							[t("Total Buy Milk Amount (+)"), total_milk_amount],
						      	[t("Cash Amount (-)"),cash_amount],
						      	[t("Prodct Amount (-)"),product_cash],
						      	[t("Previous Balance (+)"),previous_amount],
						      	[" ","____________________________"],
						      	[t("Total Amount (=)"),total.to_s + "    "+msg]
						      ]

      pdf.table(table_data,width: 500, position: :center, cell_style: {padding: 0, size: 10, :border_width => 0})
      # pdf.move_down(10)
      # pdf.text t("SUPPLIER'S SIGNATURE")+"                                                              "+t("APPROVED BY"), align: :left, size: 10
  end
end