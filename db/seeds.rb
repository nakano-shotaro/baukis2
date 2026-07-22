# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end 

common_table_names = %w(hash_locks)
common_table_names.each do |table_name| 
  path = Rails.root.join("db", "seeds", "#{table_name}.rb")
  if File.exist?(path) 
    puts "Creating #{table_name}...." 
    require(path) 
   end   
end   

table_names = %w(
  staff_members administrators staff_events customers 
  programs entries messages tags 
)

table_names.each do |table_name| 
  path = Rails.root.join("db", "seeds", Rails.env, "#{table_name}.rb") 
  if File.exist?(path) 
    puts "Creating #{table_name}...." 
    require(path)
  end     
end     
