class RentalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rental, only: [:show, :confirm, :cancel, :payment, :process_payment]
  
  def index
    @pagy, @rentals = pagy(policy_scope(Rental).includes(:instrument, instrument: :images_attachments))
    @upcoming_rentals = @rentals.upcoming
    @current_rentals = @rentals.current
    @past_rentals = @rentals.past
  end
  
  def show
    authorize @rental
  end
  
  def new
    @instrument = Instrument.friendly.find(params[:instrument_id])
    @rental = @instrument.rentals.build
    authorize @rental
  end
  
  def create
    @instrument = Instrument.friendly.find(params[:instrument_id])
    @rental = @instrument.rentals.build(rental_params)
    @rental.renter = current_user
    
    authorize @rental
    
    if @rental.save
      redirect_to payment_rental_path(@rental), notice: "Rental request created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def confirm
    authorize @rental
    
    if @rental.confirm!
      redirect_to @rental, notice: "Rental confirmed successfully!"
    else
      redirect_to @rental, alert: "Unable to confirm rental."
    end
  end
  
  def cancel
    authorize @rental
    
    if @rental.cancel!(params[:reason])
      redirect_to rentals_path, notice: "Rental cancelled successfully."
    else
      redirect_to @rental, alert: "Unable to cancel rental."
    end
  end
  
  def payment
    authorize @rental
    @stripe_public_key = Rails.application.credentials.stripe[:public_key]
  end
  
  def process_payment
    authorize @rental
    
    # Stripe payment processing would go here
    # For now, we'll just confirm the rental
    if @rental.confirm!
      redirect_to @rental, notice: "Payment successful! Your rental is confirmed."
    else
      redirect_to payment_rental_path(@rental), alert: "Payment failed. Please try again."
    end
  end
  
  private
  
  def set_rental
    @rental = Rental.find(params[:id])
  end
  
  def rental_params
    params.require(:rental).permit(:start_date, :end_date)
  end
end