# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

puts "🌱 Starting to seed the database..."

# Clear existing data in development
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  Review.destroy_all
  Rental.destroy_all
  Instrument.destroy_all
  User.destroy_all
end

puts "👥 Creating users..."

# Create admin user
admin = User.find_or_create_by!(email: "admin@musicmarketplace.com") do |user|
  user.first_name = "Admin"
  user.last_name = "User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "admin"
  user.phone = "+1 (555) 123-4567"
  user.verified_at = Time.current
end

# Create instrument owners
owners = []
15.times do |i|
  owner = User.find_or_create_by!(email: "owner#{i + 1}@example.com") do |user|
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
    user.password = "password123"
    user.password_confirmation = "password123"
    user.role = "owner"
    user.phone = "+1 (555) #{rand(100..999)}-#{rand(1000..9999)}"
    user.verified_at = Time.current - rand(1..90).days
  end
  owners << owner
end

# Create renters
renters = []
25.times do |i|
  renter = User.find_or_create_by!(email: "renter#{i + 1}@example.com") do |user|
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
    user.password = "password123"
    user.password_confirmation = "password123"
    user.role = "renter"
    user.phone = "+1 (555) #{rand(100..999)}-#{rand(1000..9999)}"
    user.verified_at = Time.current - rand(1..60).days
  end
  renters << renter
end

puts "🎵 Creating instruments..."

# Instrument data with realistic descriptions
instrument_data = [
  {
    category: "guitar", brand: "Fender", name: "Stratocaster Electric Guitar",
    description: "Classic Fender Stratocaster with maple neck and rosewood fretboard. Perfect for rock, blues, and jazz. Includes amplifier and cable. Great for beginners and experienced players alike.",
    daily_rate: 25, location: "New York, NY"
  },
  {
    category: "guitar", brand: "Gibson", name: "Les Paul Standard",
    description: "Iconic Gibson Les Paul Standard with humbucker pickups. Rich, warm tone perfect for rock and blues. Professional quality instrument with excellent sustain and playability.",
    daily_rate: 35, location: "Los Angeles, CA"
  },
  {
    category: "guitar", brand: "Taylor", name: "814ce Acoustic Guitar",
    description: "Premium Taylor acoustic guitar with sitka spruce top and Indian rosewood back and sides. Perfect for recording and live performances. Comes with hard case.",
    daily_rate: 30, location: "Nashville, TN"
  },
  {
    category: "piano", brand: "Yamaha", name: "U1 Upright Piano",
    description: "Professional Yamaha upright piano with excellent touch and tone. Perfect for classical music, jazz, and contemporary playing. Recently tuned and maintained by certified technician.",
    daily_rate: 45, location: "Chicago, IL"
  },
  {
    category: "piano", brand: "Kawai", name: "Digital Piano MP11SE",
    description: "High-end digital piano with wooden keys and advanced sound sampling. 88 weighted keys with triple sensor technology. Perfect for studio recording and live performance.",
    daily_rate: 40, location: "Boston, MA"
  },
  {
    category: "drums", brand: "Pearl", name: "Export Series Drum Kit",
    description: "Complete 5-piece Pearl drum kit with cymbals and hardware. Great for rock, pop, and jazz. Includes throne, sticks, and practice pads. Perfect for rehearsals and performances.",
    daily_rate: 50, location: "Austin, TX"
  },
  {
    category: "drums", brand: "DW", name: "Collector's Series Maple",
    description: "High-end DW Collector's maple drum kit with custom finishes. Professional quality for studio recording and touring. Includes premium hardware and cases.",
    daily_rate: 75, location: "Seattle, WA"
  },
  {
    category: "violin", brand: "Stentor", name: "Student Violin 4/4",
    description: "Quality student violin with ebony fittings and fine tuners. Perfect for beginners and intermediate players. Comes with bow, rosin, and case. Recently set up by luthier.",
    daily_rate: 15, location: "Philadelphia, PA"
  },
  {
    category: "violin", brand: "Eastman", name: "VL305 Advanced Violin",
    description: "Professional level violin with aged wood and hand-carved scroll. Excellent projection and warm tone. Perfect for advanced students and professional musicians.",
    daily_rate: 35, location: "San Francisco, CA"
  },
  {
    category: "bass", brand: "Fender", name: "Precision Bass",
    description: "Classic Fender Precision Bass with alder body and maple neck. The foundation of countless recordings. Includes bass amp and cable. Great for all musical styles.",
    daily_rate: 30, location: "Miami, FL"
  },
  {
    category: "keyboard", brand: "Nord", name: "Stage 3 88-Key",
    description: "Professional stage piano with weighted keys and premium sounds. Perfect for live performance and studio work. Includes sustain pedal and music stand.",
    daily_rate: 55, location: "Portland, OR"
  },
  {
    category: "saxophone", brand: "Yamaha", name: "YAS-480 Alto Saxophone",
    description: "Intermediate alto saxophone with excellent intonation and response. Perfect for jazz, classical, and contemporary music. Includes case, mouthpiece, and reeds.",
    daily_rate: 40, location: "New Orleans, LA"
  },
  {
    category: "trumpet", brand: "Bach", name: "Stradivarius LT180S-37",
    description: "Professional B♭ trumpet with silver-plated finish. Excellent for classical, jazz, and commercial music. Includes case and Bach mouthpiece. Recently serviced.",
    daily_rate: 25, location: "Denver, CO"
  },
  {
    category: "flute", brand: "Gemeinhardt", name: "3OB Intermediate Flute",
    description: "Silver-plated intermediate flute with open holes and B footjoint. Great projection and warm tone. Perfect for advancing students and semi-professionals.",
    daily_rate: 20, location: "Atlanta, GA"
  },
  {
    category: "ukulele", brand: "Martin", name: "5K Concert Ukulele",
    description: "Premium concert ukulele with solid mahogany top and koa back and sides. Beautiful tone and excellent craftsmanship. Perfect for recording and performances.",
    daily_rate: 18, location: "Honolulu, HI"
  },
  {
    category: "guitar", brand: "Martin", name: "D-28 Acoustic Guitar",
    description: "Legendary Martin dreadnought with sitka spruce top and East Indian rosewood back and sides. The gold standard for acoustic guitars. Recently professionally set up.",
    daily_rate: 40, location: "Dallas, TX"
  },
  {
    category: "keyboard", brand: "Roland", name: "RD-2000 Stage Piano",
    description: "Professional stage piano with hybrid sound engine combining samples and modeling. Perfect for live performance with extensive sound library and real-time controls.",
    daily_rate: 50, location: "Minneapolis, MN"
  },
  {
    category: "drums", brand: "Gretsch", name: "Catalina Maple 5-Piece",
    description: "Gretsch Catalina maple drum kit with warm, punchy tone. Great for jazz, rock, and pop. Includes all necessary hardware and professional setup. Recently tuned.",
    daily_rate: 45, location: "Las Vegas, NV"
  },
  {
    category: "bass", brand: "Music Man", name: "StingRay 4-String Bass",
    description: "Classic Music Man StingRay bass with active electronics and distinctive tone. Perfect for funk, rock, and pop. Includes premium bass amp and all cables.",
    daily_rate: 35, location: "Phoenix, AZ"
  },
  {
    category: "guitar", brand: "PRS", name: "Custom 24 Electric Guitar",
    description: "Premium PRS Custom 24 with figured maple top and mahogany body. Versatile guitar perfect for any style. Includes tube amp and effects pedal. Professional setup.",
    daily_rate: 45, location: "Salt Lake City, UT"
  }
]

instruments = []
instrument_data.each_with_index do |data, index|
  instrument = Instrument.find_or_create_by!(
    name: data[:name],
    brand: data[:brand],
    owner: owners[index % owners.length]
  ) do |inst|
    inst.category = data[:category]
    inst.condition = [:excellent, :good].sample
    inst.description = data[:description]
    inst.daily_rate = data[:daily_rate]
    inst.weekly_rate = data[:daily_rate] * 6.5
    inst.monthly_rate = data[:daily_rate] * 25
    inst.location = data[:location]
    inst.available = true
  end
  instruments << instrument
end

puts "📅 Creating rentals..."

# Create rentals (mix of past, current, and future)
rentals = []
50.times do |i|
  instrument = instruments.sample
  renter = renters.sample
  
  # Ensure renter is not the owner
  next if renter == instrument.owner
  
  # Create rentals across different time periods
  case i % 3
  when 0 # Past rentals (completed)
    start_date = Faker::Date.between(from: 3.months.ago, to: 1.month.ago)
    end_date = start_date + rand(1..14).days
    status = "completed"
  when 1 # Current/upcoming rentals
    start_date = Faker::Date.between(from: Date.current, to: 1.month.from_now)
    end_date = start_date + rand(1..10).days
    status = ["confirmed", "active"].sample
  else # Recent past rentals
    start_date = Faker::Date.between(from: 2.months.ago, to: 2.weeks.ago)
    end_date = start_date + rand(2..7).days
    status = "completed"
  end
  
  total_amount = instrument.calculate_rental_price(start_date, end_date)
  
  rental = Rental.new(
    instrument: instrument,
    renter: renter,
    start_date: start_date,
    end_date: end_date,
    total_amount: total_amount,
    status: status
  )
  
  # Skip validations for seed data to allow past dates
  rental.save(validate: false)
  
  rentals << rental if rental.persisted?
end

puts "⭐ Creating reviews..."

# Create reviews for completed rentals
completed_rentals = rentals.select(&:completed?)
completed_rentals.each do |rental|
  # 80% chance of renter reviewing owner
  if rand < 0.8
    Review.find_or_create_by!(
      rental: rental,
      reviewer: rental.renter,
      reviewee: rental.owner
    ) do |review|
      review.rating = [3, 4, 4, 5, 5].sample # Mostly positive reviews
      review.comment = [
        "Great instrument and smooth rental process. Highly recommended!",
        "The instrument was in excellent condition and the owner was very helpful.",
        "Perfect for my recording session. Would rent again!",
        "Good quality instrument, exactly as described.",
        "Owner was responsive and the instrument sounded amazing.",
        "Great experience overall. The instrument was well-maintained.",
        "Exactly what I needed for my performance. Thanks!",
        "Professional quality instrument and excellent service.",
        "The instrument was clean and in perfect working condition.",
        "Smooth transaction and great communication throughout."
      ].sample
    end
  end
  
  # 60% chance of owner reviewing renter
  if rand < 0.6
    Review.find_or_create_by!(
      rental: rental,
      reviewer: rental.owner,
      reviewee: rental.renter
    ) do |review|
      review.rating = [4, 4, 5, 5, 5].sample # Very positive for renters
      review.comment = [
        "Excellent renter! Took great care of my instrument.",
        "Very responsible and communicative throughout the rental.",
        "Returned the instrument in perfect condition. Highly recommended!",
        "Great renter, would definitely rent to again.",
        "Professional and respectful. No issues at all.",
        "Prompt communication and careful handling of the instrument.",
        "Trustworthy renter who treated my instrument with respect.",
        "Perfect rental experience. Highly recommended renter!",
        "Returned on time and in excellent condition.",
        "Great communication and very responsible with the instrument."
      ].sample
    end
  end
end

puts "📊 Seed data summary:"
puts "- Users created: #{User.count} (1 admin, #{owners.count} owners, #{renters.count} renters)"
puts "- Instruments created: #{Instrument.count}"
puts "- Rentals created: #{Rental.count}"
puts "- Reviews created: #{Review.count}"

puts "🎉 Seeding completed successfully!"

# Development environment specific data
if Rails.env.development?
  puts "\n📝 Development login credentials:"
  puts "Admin: admin@musicmarketplace.com / password123"
  puts "Owner example: owner1@example.com / password123"
  puts "Renter example: renter1@example.com / password123"
end
