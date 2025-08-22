class Rental < ApplicationRecord
  # Enums
  enum :status, { 
    pending: 0,
    confirmed: 1,
    active: 2,
    completed: 3,
    cancelled: 4,
    disputed: 5
  }
  
  # Associations
  belongs_to :instrument
  belongs_to :renter, class_name: "User"
  has_one :owner, through: :instrument, source: :owner
  has_many :reviews, dependent: :destroy
  
  # Validations
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validate :validate_dates
  validate :validate_availability
  validate :validate_renter_can_rent
  
  # Scopes
  scope :upcoming, -> { where("start_date > ?", Date.current).order(start_date: :asc) }
  scope :current, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }
  scope :past, -> { where("end_date < ?", Date.current).order(end_date: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :for_owner, ->(user) { joins(:instrument).where(instruments: { owner_id: user.id }) }
  scope :for_renter, ->(user) { where(renter_id: user.id) }
  
  # Callbacks
  before_validation :calculate_total_amount, on: :create
  after_create :send_booking_notifications
  after_update :handle_status_change
  
  # State machine methods
  def confirm!
    return false unless pending?
    
    transaction do
      update!(status: :confirmed)
      # Create Stripe payment intent here
      send_confirmation_notifications
    end
  end
  
  def activate!
    return false unless confirmed? && Date.current >= start_date
    
    update!(status: :active)
    send_rental_started_notifications
  end
  
  def complete!
    return false unless active? && Date.current > end_date
    
    update!(status: :completed)
    instrument.update!(available: true)
    send_completion_notifications
  end
  
  def cancel!(reason = nil)
    return false if completed? || cancelled?
    
    transaction do
      update!(status: :cancelled)
      # Process refund through Stripe if needed
      instrument.update!(available: true) if was_blocking_availability?
      send_cancellation_notifications(reason)
    end
  end
  
  # Instance methods
  def rental_days
    (end_date - start_date).to_i + 1
  end
  
  def can_be_reviewed_by?(user)
    completed? && (user == renter || user == owner)
  end
  
  def reviewed_by?(user)
    reviews.exists?(reviewer: user)
  end
  
  def overdue?
    active? && Date.current > end_date
  end
  
  def days_until_start
    return 0 if Date.current >= start_date
    (start_date - Date.current).to_i
  end
  
  def days_remaining
    return 0 if Date.current > end_date
    (end_date - Date.current).to_i
  end
  
  def refundable?
    pending? || (confirmed? && days_until_start > 2)
  end
  
  def refund_amount
    return total_amount if pending?
    return total_amount * 0.9 if days_until_start > 7
    return total_amount * 0.5 if days_until_start > 2
    0
  end
  
  private
  
  def validate_dates
    return unless start_date && end_date
    
    if start_date < Date.current
      errors.add(:start_date, "cannot be in the past")
    end
    
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
    
    if rental_days > 365
      errors.add(:base, "Rental period cannot exceed 365 days")
    end
  end
  
  def validate_availability
    return unless instrument && start_date && end_date
    
    unless instrument.available_for_dates?(start_date, end_date)
      errors.add(:base, "Instrument is not available for selected dates")
    end
  end
  
  def validate_renter_can_rent
    return unless renter
    
    unless renter.can_rent?
      errors.add(:base, "Renter must be verified to book rentals")
    end
    
    if renter == instrument&.owner
      errors.add(:base, "Cannot rent your own instrument")
    end
  end
  
  def calculate_total_amount
    return unless instrument && start_date && end_date
    
    self.total_amount = instrument.calculate_rental_price(start_date, end_date)
  end
  
  def was_blocking_availability?
    [:pending, :confirmed, :active].include?(status_before_last_save.to_sym)
  end
  
  def send_booking_notifications
    # RentalMailer.booking_request(self).deliver_later
    # Notify owner via Turbo Streams
  end
  
  def send_confirmation_notifications
    # RentalMailer.booking_confirmed(self).deliver_later
  end
  
  def send_rental_started_notifications
    # RentalMailer.rental_started(self).deliver_later
  end
  
  def send_completion_notifications
    # RentalMailer.rental_completed(self).deliver_later
  end
  
  def send_cancellation_notifications(reason)
    # RentalMailer.rental_cancelled(self, reason).deliver_later
  end
  
  def handle_status_change
    if saved_change_to_status?
      case status
      when "confirmed"
        instrument.update!(available: false)
      when "cancelled", "completed"
        instrument.update!(available: true)
      end
    end
  end
end