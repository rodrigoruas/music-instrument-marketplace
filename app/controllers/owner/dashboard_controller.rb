class Owner::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_owner!
  
  def index
    @instruments = current_user.instruments.includes(:rentals, images_attachments: :blob)
    @total_instruments = @instruments.count
    @active_rentals = Rental.for_owner(current_user).active.count
    @pending_rentals = Rental.for_owner(current_user).pending.includes(:instrument, :renter)
    
    # Revenue calculations
    @total_revenue = Rental.for_owner(current_user).completed.sum(:total_amount)
    @monthly_revenue = Rental.for_owner(current_user)
                            .completed
                            .where("created_at >= ?", 30.days.ago)
                            .sum(:total_amount)
    
    # Recent activity
    @recent_rentals = Rental.for_owner(current_user)
                           .includes(:instrument, :renter)
                           .order(created_at: :desc)
                           .limit(5)
    
    # Upcoming rentals
    @upcoming_rentals = Rental.for_owner(current_user)
                             .upcoming
                             .includes(:instrument, :renter)
                             .limit(5)
    
    # Chart data for revenue over time
    @revenue_chart_data = prepare_revenue_chart_data
  end
  
  private
  
  def ensure_owner!
    unless current_user.owner? || current_user.admin?
      redirect_to root_path, alert: "You must be an owner to access this area."
    end
  end
  
  def prepare_revenue_chart_data
    last_30_days = (0..29).map { |i| i.days.ago.to_date }
    revenue_by_day = Rental.for_owner(current_user)
                          .completed
                          .where("created_at >= ?", 30.days.ago)
                          .group_by_day(:created_at)
                          .sum(:total_amount)
    
    last_30_days.map do |date|
      {
        date: date.strftime("%b %d"),
        revenue: revenue_by_day[date] || 0
      }
    end
  end
end