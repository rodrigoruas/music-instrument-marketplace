module ApplicationHelper
  include Pagy::Frontend
  
  def format_currency(amount)
    number_to_currency(amount, unit: "$", precision: 2)
  end
  
  def format_date(date)
    date.strftime("%B %d, %Y") if date
  end
  
  def format_date_short(date)
    date.strftime("%b %d") if date
  end
  
  def instrument_condition_badge(condition)
    color = case condition
            when "excellent" then "bg-green-100 text-green-800"
            when "good" then "bg-blue-100 text-blue-800"
            when "fair" then "bg-yellow-100 text-yellow-800"
            when "poor" then "bg-red-100 text-red-800"
            else "bg-gray-100 text-gray-800"
            end
    
    content_tag(:span, condition.capitalize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{color}")
  end
  
  def rental_status_badge(status)
    color = case status
            when "pending" then "bg-yellow-100 text-yellow-800"
            when "confirmed" then "bg-blue-100 text-blue-800"
            when "active" then "bg-green-100 text-green-800"
            when "completed" then "bg-gray-100 text-gray-800"
            when "cancelled" then "bg-red-100 text-red-800"
            when "disputed" then "bg-purple-100 text-purple-800"
            else "bg-gray-100 text-gray-800"
            end
    
    content_tag(:span, status.capitalize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{color}")
  end
  
  def star_rating(rating, max_stars = 5)
    full_stars = rating.to_i
    half_star = (rating - full_stars) >= 0.5
    empty_stars = max_stars - full_stars - (half_star ? 1 : 0)
    
    content_tag(:div, class: "flex items-center") do
      stars = []
      
      full_stars.times do
        stars << content_tag(:svg, class: "w-5 h-5 text-yellow-400 fill-current", viewBox: "0 0 20 20") do
          content_tag(:path, "", d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z")
        end
      end
      
      if half_star
        stars << content_tag(:svg, class: "w-5 h-5 text-yellow-400", viewBox: "0 0 20 20") do
          content_tag(:path, "", d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z", fill: "url(#half)")
        end
      end
      
      empty_stars.times do
        stars << content_tag(:svg, class: "w-5 h-5 text-gray-300", viewBox: "0 0 20 20") do
          content_tag(:path, "", d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z", fill: "none", stroke: "currentColor", stroke_width: "1")
        end
      end
      
      safe_join(stars)
    end
  end
  
  def user_avatar(user, size = "h-10 w-10")
    if user.avatar&.attached?
      image_tag user.avatar, class: "#{size} rounded-full object-cover", alt: user.full_name
    else
      content_tag(:div, class: "#{size} rounded-full bg-indigo-100 flex items-center justify-center") do
        content_tag(:span, user.full_name.split.map(&:first).join.upcase, class: "text-indigo-600 font-medium text-sm")
      end
    end
  end
  
  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "bg-green-50 text-green-800 border-green-200"
    when :alert, :error
      "bg-red-50 text-red-800 border-red-200"
    when :warning
      "bg-yellow-50 text-yellow-800 border-yellow-200"
    else
      "bg-blue-50 text-blue-800 border-blue-200"
    end
  end
end