class Owner::InstrumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_owner!
  before_action :set_instrument, only: [:show, :edit, :update, :destroy, :toggle_availability]
  
  def index
    @pagy, @instruments = pagy(
      current_user.instruments
                  .includes(:rentals, images_attachments: :blob)
                  .order(created_at: :desc)
    )
  end
  
  def show
    @rentals = @instrument.rentals.includes(:renter).order(created_at: :desc)
    @revenue = @instrument.earnings
    @average_rating = @instrument.average_rating
  end
  
  def new
    @instrument = current_user.instruments.build
    authorize @instrument
  end
  
  def create
    @instrument = current_user.instruments.build(instrument_params)
    authorize @instrument
    
    if @instrument.save
      redirect_to owner_instrument_path(@instrument), notice: "Instrument created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    authorize @instrument
  end
  
  def update
    authorize @instrument
    
    if @instrument.update(instrument_params)
      redirect_to owner_instrument_path(@instrument), notice: "Instrument updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    authorize @instrument
    @instrument.destroy!
    redirect_to owner_instruments_path, notice: "Instrument deleted successfully!"
  end
  
  def toggle_availability
    authorize @instrument
    @instrument.update!(available: !@instrument.available)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: owner_instruments_path) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "instrument_#{@instrument.id}_availability",
          partial: "owner/instruments/availability_toggle",
          locals: { instrument: @instrument }
        )
      end
    end
  end
  
  private
  
  def set_instrument
    @instrument = current_user.instruments.friendly.find(params[:id])
  end
  
  def ensure_owner!
    unless current_user.owner? || current_user.admin?
      redirect_to root_path, alert: "You must be an owner to access this area."
    end
  end
  
  def instrument_params
    params.require(:instrument).permit(
      :name, :brand, :model, :category, :condition,
      :description, :daily_rate, :weekly_rate, :monthly_rate,
      :location, :available, images: []
    )
  end
end