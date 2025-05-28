class Fittonia::ContactsController < ApplicationController
	skip_before_action :authenticate_request

  def create
    contact = Fittonia::Contact.new(contact_params)
    if contact.save
      render json: { data: contact, message: 'contact created successfully' },
             status: :created
    else
      render json: { errors: contact.errors }
    end
  end

  private

  def contact_params
    params.permit(:first_name, :last_name, :email, :phone_number, :message, :enquiry_agreement, :products_agreement, :budget)
  end
end
