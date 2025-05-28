class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phone_number, :address, :decode_text, :image, :my_dairy, :customer_account, :sid, :grade, :chart, :rate_type

  def image
    return unless object.image.attached?

    {
      id: object.image.id,
      url: ENV['BASE_URL'] + Rails.application.routes.url_helpers.rails_blob_url(
        object.image, only_path: true
      )
    }
  end

  def customer_account
    credit = object.buy_milks.sum(:amount).round(2)
    deposit = object.deposit_histories.sum(:amount).round(2)
    {
      id: object.customer_account&.id,
      credit: credit,
      deposit: deposit,
      balance: (credit - deposit).round(2),
      customer_id: object.id,
    }
  end
end
