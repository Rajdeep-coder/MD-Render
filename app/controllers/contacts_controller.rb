class ContactsController < ApplicationController
	skip_before_action :authenticate_request

	def create
    contact = Contact.new(contact_params)
    if contact.save
      render json: { message: 'contact created successfully' },
             status: :created
    else
      render json: { errors: format_activerecord_errors(contact.errors) }, status: :unprocessable_entity
    end
  end

  private

  def contact_params
  	params.require(:data).permit(:name, :email, :phone, :message)
  end
end
