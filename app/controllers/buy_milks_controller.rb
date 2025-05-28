class BuyMilksController < ApplicationController
  include PdfDownload
  include BillGenration
  include DairyAudit
  before_action :check_current_user, except: %i[credit_history bill_generation]
  before_action :check_customer, only: %i[create]
  before_action :find_buy_milk, only: %i[show update destroy]

  def create
    unless params[:data][:confirmed].present?
      duplicates = BuyMilk.where(duplicate_params)
      if duplicates.present?
        return render json: { message: 'Duplicate entry Found', duplicates: duplicates }, status: :ok
      end
    end
    buy_milk = BuyMilk.new(buy_milk_params)
    if buy_milk.save
      render json: { data: BuyMilkSerializer.new(buy_milk), message: 'buy_milk created successfully' },
               status: :created
    else
      render json: { errors: format_activerecord_errors(buy_milk.errors) }, status: :unprocessable_entity
    end 
  end

  def show
    render json: { data: BuyMilkSerializer.new(@buy_milk) }, status: :ok
  end

  def update
    amount = @buy_milk.amount
    if @buy_milk.update(buy_milk_params)
      mange_customer_account(@buy_milk, amount)
      render json: { data: BuyMilkSerializer.new(@buy_milk), message: 'buy_milk update successfully' }, status: :ok 
    else
      render json: { errors: format_activerecord_errors(@buy_milk.errors) }, status: :unprocessable_entity
    end
  end

  def credit_history
    if @current_user.instance_of?(Customer)
      pagy, data = pagination(@current_user.buy_milks&.order(date: :desc))
      render json: { data: data&.map{|credit| BuyMilkSerializer.new(credit) } , pagination: pagy}, status: :ok
    else
      pagy, data = pagination(@current_user.customers.find_by_id(params[:customer_id])&.buy_milks&.order(date: :desc))
      render json: { data: data&.map{|credit| BuyMilkSerializer.new(credit) }, pagination: pagy }, status: :ok
    end
  end

  def index
    data, meta = apply_filters
    pagy, data = if params[:date].present?
                  meta[:is_added] = @current_user.sell_milks.find_by(date: params[:date], shift: params[:shift]).present?
                  [{}, data]
                 else
                  pagination(data)
                 end
    render json: { data: data&.map{|credit| BuyMilkSerializer.new(credit) }, meta: meta, pagination: pagy }, status: :ok
  end

  def pdf_download
    pdf = init_pdf
    data, meta = apply_filters(order: :asc)
    customer_info(pdf, data)
    pdf.move_down(20)
    if meta.present? && params['page'] != "pdf-format"
      summary(pdf, meta, data)
    end
    if params[:platform] == 'mobile'
      render json: { url: genrate_pdf_url(pdf), filename: "#{@filename}.pdf" }
    else
      headers['Content-Disposition'] = "#{@filename}.pdf"
      send_data pdf.render, filename: "#{@filename}.pdf"
    end
  end

  def bill_generation
    pdf = init_pdf
    data, meta = apply_filters(order: :asc)
    customer_info_one(pdf, data, meta)
    if params[:platform] == 'mobile'
      render json: { url: genrate_pdf_url(pdf), filename: "#{@filename}.pdf" }
    else
      headers['Content-Disposition'] = "#{@filename}.pdf"
      send_data pdf.render, filename: "#{@filename}.pdf"
    end
  end

  def customer_summury
    pdf = init_pdf
    pdf.move_down(10)
    pdf.text "#{@current_user.dairy_name}", size: 16, style: :bold, align: :center
    pdf.move_down(5)
    address = @current_user.address
    pdf.text "#{address&.city}, #{address&.state}, #{address&.pin}, #{address&.country}", size: 12, align: :center
    pdf.text "#{@current_user.owner_name} : #{@current_user.phone_number}", size: 12, align: :center
    pdf.move_down(10)
    pdf.text t("Date")+": #{params[:from_date]}" +t("to")+" #{params[:to_date]}", size: 14, align: :center
    pdf.move_down(20)
    data, meta = apply_filters(order: :asc)
    all_bill(pdf, data)
    summary(pdf, meta, data)
    if params[:platform] == 'mobile'
      render json: { url: genrate_pdf_url(pdf), filename: "#{@filename}.pdf" }
    else
      headers['Content-Disposition'] = "#{@filename}.pdf"
      send_data pdf.render, filename: "#{@filename}.pdf"
    end
  end

  def audit_bill
    pdf = init_audit

    if params[:platform] == 'mobile'
      render json: { url: genrate_pdf_url(pdf), filename: "#{@filename}.pdf" }
    else
      headers['Content-Disposition'] = "milkdairy-audit-report.pdf"
      send_data pdf.render, filename: "MilkDairy-audit-report.pdf"
    end
  end

  def destroy
    if @buy_milk.destroy
      mange_customer_account(@buy_milk,nil)
      render json: { message: "Record delete successfully"}, status: :ok 
    else
      render json: { errors: format_activerecord_errors(@buy_milk.errors) }, status: :unprocessable_entity
    end
  end

  private

  def check_customer
    return if @current_user.customers.find_by_id(params[:data][:customer_id]).present?

    render json: { errors: "You have not authority to do this action" }, status: :unprocessable_entity
  end

  def check_current_user
    return if @current_user.instance_of?(MyDairy)

    render json: { errors: 'You have not authority to do this action' },status: :unprocessable_entity
  end

  def buy_milk_params
    params.require(:data).permit(:fat, :clr, :snf, :quntity, :amount, :customer_id, :shift, :date,
      :chart_id, :rate_type, :grade_id, :little_rate)
  end

  def duplicate_params
    params.require(:data).permit(:date, :shift, :customer_id)
  end

  def apply_filters(order: :desc)
    @current_user = @current_user.my_dairy if @current_user.class == Customer
    buy_milks = BuyMilk.joins(customer: :my_dairy).where(my_dairy: { id: @current_user })
    buy_milks = buy_milks.where(date: params[:date]) if params[:date].present?
    buy_milks = buy_milks.where(shift: params[:shift]) if params[:shift].present?
    buy_milks = buy_milks.where(customer_id: params[:customer_id]) if params[:customer_id].present?

    if params[:from_date].present? && params[:to_date].present?
      buy_milks = buy_milks.where(date: params[:from_date]..params[:to_date])
    end

    meta = {}

    if params[:meta].present?
      fat_avg = clr_avg = snf_avg = 0
      buy_milks.each do |obj|
        fat_avg += (obj.fat * obj.quntity) 
        clr_avg += (obj.clr * obj.quntity)  if obj.clr.present?
        snf_avg += (obj.snf * obj.quntity)  if obj.snf.present?
      end

      total_quntity = buy_milks.sum(:quntity)&.round(2)
      meta = { 
               total_quntity: total_quntity,
               total_amount: buy_milks.sum(:amount)&.round(2),
               fat_avg: (fat_avg/total_quntity)&.round(2) ,
               snf_avg: (snf_avg/total_quntity)&.round(2) ,
               clr_avg: (clr_avg/total_quntity)&.round(2) 
             }
    end

    buy_milks = if params[:sort].present? && params[:sort][:key].present?
                  buy_milks.order("#{params[:sort][:key]} #{params[:sort][:direction]}")
                else
                  buy_milks.order(date: order)
                end
    [buy_milks, meta]
  end

  def find_buy_milk
    @buy_milk = BuyMilk.joins(customer: :my_dairy).where(my_dairy: { id: @current_user.id }).find_by_id(params[:id])
    unless @buy_milk.present?
      render json: { errors: "Record not found"}, status: :unprocessable_entity
    end
  end

  def mange_customer_account(obj, amount)
    customer_account =  obj.customer.customer_account
    if amount.present?
      credit = customer_account.credit  - amount
      credit += obj.amount
    else
      credit = customer_account.credit  - obj.amount
    end
    balance = credit - customer_account.deposit 
    customer_account.update(credit: credit.round(2), balance:balance.round(2))
  end

  def genrate_pdf_url(pdf)
    pdf_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(pdf.render),
      filename: "#{@filename}.pdf",
      content_type: 'application/pdf'
    )
    DeleteBlobJob.set(wait: 15.minutes).perform_later(pdf_blob.id)
    ENV['BASE_URL'] + Rails.application.routes.url_helpers.rails_blob_url(
    pdf_blob, only_path: true)
  end
end
