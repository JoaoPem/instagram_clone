namespace :dev do
  desc "Set up the development environment"
  task setup: :environment do
    if Rails.env.development?
      puts "Dropping DB..."
      %x(rails db:drop)
      puts "Creating DB..."
      %x(rails db:create)
      puts "Migrating DB..."
      %x(rails db:migrate)
    else
      puts "You aren't in the development environment!"
    end
  end
end
