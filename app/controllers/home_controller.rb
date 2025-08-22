class HomeController < ApplicationController
  def index
    @featured_instruments = Instrument.available
                                     .includes(:owner, images_attachments: :blob)
                                     .limit(8)
    @recent_reviews = Review.includes(:reviewer, :reviewee, rental: :instrument)
                           .recent
                           .limit(6)
    @categories = Instrument.categories.keys
  end
end