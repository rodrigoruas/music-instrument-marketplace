class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # Enums
  enum :role, { renter: 0, owner: 1, admin: 2 }
  
  # Associations
  has_many :instruments, foreign_key: :owner_id, dependent: :destroy
  has_many :rentals, foreign_key: :renter_id, dependent: :destroy
  has_many :rented_instruments, through: :rentals, source: :instrument
  has_many :reviews_given, class_name: "Review", foreign_key: :reviewer_id, dependent: :destroy
  has_many :reviews_received, class_name: "Review", foreign_key: :reviewee_id, dependent: :destroy
  
  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true, format: { with: /\A[\d\s\-\+\(\)]+\z/ }, allow_blank: true
  
  # Callbacks
  after_create :send_welcome_email
  
  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def verified?
    verified_at.present?
  end
  
  def verify!
    update(verified_at: Time.current)
  end
  
  def can_rent?
    verified? && renter?
  end
  
  def can_list_instruments?
    verified? && (owner? || admin?)
  end
  
  def average_rating
    reviews_received.average(:rating) || 0
  end
  
  def total_reviews
    reviews_received.count
  end
  
  def total_rentals_as_owner
    instruments.joins(:rentals).count
  end
  
  def total_rentals_as_renter
    rentals.count
  end
  
  private
  
  def send_welcome_email
    # UserMailer.welcome(self).deliver_later
  end
end