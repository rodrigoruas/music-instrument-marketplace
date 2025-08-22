class InstrumentsController < ApplicationController
  before_action :set_instrument, only: [:show, :availability]
  
  def index
    @pagy, @instruments = pagy(
      policy_scope(Instrument)
        .includes(:owner, images_attachments: :blob)
        .then { |scope| filter_instruments(scope) }
    )
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def show
    authorize @instrument
    @related_instruments = Instrument.available
                                    .where(category: @instrument.category)
                                    .where.not(id: @instrument.id)
                                    .limit(4)
    @reviews = @instrument.rentals
                         .joins(:reviews)
                         .includes(reviews: [:reviewer])
                         .map(&:reviews)
                         .flatten
  end
  
  def search
    @query = params[:q]
    @pagy, @instruments = pagy(
      policy_scope(Instrument)
        .search(@query)
        .includes(:owner, images_attachments: :blob)
    )
    
    respond_to do |format|
      format.html { render :index }
      format.turbo_stream
    end
  end
  
  def availability
    authorize @instrument, :show?
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    
    available = @instrument.available_for_dates?(start_date, end_date)
    price = @instrument.calculate_rental_price(start_date, end_date)
    
    render json: {
      available: available,
      price: price,
      formatted_price: helpers.number_to_currency(price)
    }
  rescue ArgumentError
    render json: { error: "Invalid date format" }, status: :unprocessable_entity
  end
  
  private
  
  def set_instrument
    @instrument = Instrument.friendly.find(params[:id])
  end
  
  def filter_instruments(scope)
    scope = scope.by_category(params[:category]) if params[:category].present?
    scope = scope.by_condition(params[:condition]) if params[:condition].present?
    scope = scope.price_range(params[:min_price], params[:max_price]) if params[:min_price].present? && params[:max_price].present?
    scope = scope.nearby(params[:lat], params[:lng], params[:distance] || 10) if params[:lat].present? && params[:lng].present?
    
    case params[:sort]
    when "price_asc"
      scope.order(daily_rate: :asc)
    when "price_desc"
      scope.order(daily_rate: :desc)
    when "newest"
      scope.order(created_at: :desc)
    when "popular"
      scope.left_joins(:rentals).group(:id).order("COUNT(rentals.id) DESC")
    else
      scope.order(created_at: :desc)
    end
  end
end