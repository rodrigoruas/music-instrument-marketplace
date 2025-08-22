class Instrument < ApplicationRecord
  # FriendlyId for SEO-friendly URLs
  extend FriendlyId
  friendly_id :name_with_brand, use: :slugged
  
  # Enums
  enum :category, { 
    guitar: 0, 
    piano: 1, 
    drums: 2, 
    violin: 3,
    bass: 4,
    keyboard: 5,
    saxophone: 6,
    trumpet: 7,
    flute: 8,
    ukulele: 9,
    other: 10 
  }
  
  enum :condition, { 
    excellent: 0,
    good: 1,
    fair: 2,
    poor: 3
  }
  
  # Associations
  belongs_to :owner, class_name: "User"
  has_many :rentals, dependent: :destroy
  has_many :renters, through: :rentals, source: :renter
  has_many_attached :images
  
  # Validations
  validates :name, presence: true
  validates :brand, presence: true
  validates :category, presence: true
  validates :condition, presence: true
  validates :description, presence: true, length: { minimum: 50, maximum: 1000 }
  validates :daily_rate, presence: true, numericality: { greater_than: 0 }
  validates :weekly_rate, presence: true, numericality: { greater_than: 0 }
  validates :monthly_rate, presence: true, numericality: { greater_than: 0 }
  validates :location, presence: true
  validate :validate_pricing_logic
  validate :validate_image_count
  
  # Geocoding
  geocoded_by :location
  after_validation :geocode, if: :location_changed?
  
  # Scopes
  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where(available: false) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_condition, ->(condition) { where(condition: condition) }
  scope :nearby, ->(latitude, longitude, distance = 10) {
    near([latitude, longitude], distance, units: :km)
  }
  scope :price_range, ->(min, max) { where(daily_rate: min..max) }
  scope :search, ->(query) {
    where("name ILIKE :q OR brand ILIKE :q OR description ILIKE :q", q: "%#{query}%")
  }
  
  # Callbacks
  before_save :calculate_suggested_rates, if: :daily_rate_changed?
  
  # Instance methods
  def available_for_dates?(start_date, end_date)
    return false unless available?
    
    conflicting_rentals = rentals
      .where(status: [:pending, :confirmed, :active])
      .where.not("end_date < ? OR start_date > ?", start_date, end_date)
    
    conflicting_rentals.empty?
  end
  
  def calculate_rental_price(start_date, end_date)
    days = (end_date - start_date).to_i + 1
    
    if days >= 30
      months = days / 30
      remaining_days = days % 30
      (months * monthly_rate) + (remaining_days * daily_rate)
    elsif days >= 7
      weeks = days / 7
      remaining_days = days % 7
      (weeks * weekly_rate) + (remaining_days * daily_rate)
    else
      days * daily_rate
    end
  end
  
  def average_rating
    rentals.joins(:reviews).average("reviews.rating") || 0
  end
  
  def total_reviews
    rentals.joins(:reviews).count
  end
  
  def times_rented
    rentals.where(status: [:completed, :active]).count
  end
  
  def earnings
    rentals.where(status: :completed).sum(:total_amount)
  end
  
  def primary_image
    images.first
  end
  
  def name_with_brand
    "#{brand} #{name}"
  end
  
  private
  
  def validate_pricing_logic
    return unless daily_rate && weekly_rate && monthly_rate
    
    if weekly_rate >= daily_rate * 7
      errors.add(:weekly_rate, "should be less than 7 times the daily rate")
    end
    
    if monthly_rate >= daily_rate * 30
      errors.add(:monthly_rate, "should be less than 30 times the daily rate")
    end
  end
  
  def validate_image_count
    if images.length > 10
      errors.add(:images, "cannot exceed 10 images")
    end
  end
  
  def calculate_suggested_rates
    if daily_rate_changed? && !weekly_rate_changed?
      self.weekly_rate = daily_rate * 6.5 # Slight discount for weekly
    end
    
    if daily_rate_changed? && !monthly_rate_changed?
      self.monthly_rate = daily_rate * 25 # Better discount for monthly
    end
  end
  
  def should_generate_new_friendly_id?
    name_changed? || brand_changed? || super
  end
end