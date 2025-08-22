class RentalPolicy < ApplicationPolicy
  def index?
    user.present?
  end
  
  def show?
    user == record.renter || user == record.owner || user&.admin?
  end
  
  def create?
    user&.can_rent? && user != record.instrument.owner
  end
  
  def new?
    user&.can_rent?
  end
  
  def confirm?
    user == record.owner && record.pending?
  end
  
  def cancel?
    (user == record.renter || user == record.owner) && record.refundable?
  end
  
  def payment?
    user == record.renter && record.confirmed?
  end
  
  def process_payment?
    payment?
  end
  
  def approve?
    user == record.owner && record.pending?
  end
  
  def reject?
    user == record.owner && record.pending?
  end
  
  def complete?
    user == record.owner && record.active? && Date.current > record.end_date
  end
  
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.for_renter(user).or(scope.for_owner(user))
      end
    end
  end
end