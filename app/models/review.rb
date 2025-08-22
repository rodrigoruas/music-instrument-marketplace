class Review < ApplicationRecord
  # Associations
  belongs_to :rental
  belongs_to :reviewer, class_name: "User"
  belongs_to :reviewee, class_name: "User"
  
  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 500 }
  validates :reviewer_id, uniqueness: { scope: :rental_id, message: "has already reviewed this rental" }
  validate :validate_rental_completed
  validate :validate_reviewer_participated
  
  # Scopes
  scope :positive, -> { where("rating >= ?", 4) }
  scope :negative, -> { where("rating < ?", 3) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_instrument, ->(instrument) { joins(:rental).where(rentals: { instrument_id: instrument.id }) }
  
  # Callbacks
  after_create :update_user_ratings_cache
  after_update :update_user_ratings_cache
  after_destroy :update_user_ratings_cache
  
  # Instance methods
  def from_owner?
    reviewer == rental.owner
  end
  
  def from_renter?
    reviewer == rental.renter
  end
  
  def sentiment
    case rating
    when 5 then "excellent"
    when 4 then "good"
    when 3 then "fair"
    when 2 then "poor"
    when 1 then "terrible"
    end
  end
  
  private
  
  def validate_rental_completed
    return unless rental
    
    unless rental.completed?
      errors.add(:base, "Can only review completed rentals")
    end
  end
  
  def validate_reviewer_participated
    return unless rental && reviewer
    
    unless [rental.renter_id, rental.owner.id].include?(reviewer.id)
      errors.add(:base, "Only rental participants can leave reviews")
    end
    
    if reviewer == reviewee
      errors.add(:base, "Cannot review yourself")
    end
    
    # Ensure the review is for the correct party
    if reviewer == rental.renter && reviewee != rental.owner
      errors.add(:base, "Renter can only review the owner")
    elsif reviewer == rental.owner && reviewee != rental.renter
      errors.add(:base, "Owner can only review the renter")
    end
  end
  
  def update_user_ratings_cache
    # Update cached rating values for better performance
    # This could be stored in Redis or database columns
  end
end