# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# password_digest: "$2a$10$77fJKtz3cZiUSN2/JBH0m.i0YgbqHbq/wd43SOJiKtjzi/GyHZSuq"

require "faker"

puts "Seeding employees"
20.times do |count|
  if count == 0
    Employee.create(
      id: (count + 1),
      first_name: "Reymundo",
      last_name: "Tenorio",
      email: "reymundotenorio@gmail.com",
      phone: "88888888",
      role: "Administrator",
      state: true
    )

  else
    begin
      Employee.create(
        id: (count + 1),
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email,
        phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}",
        role: ["Administrator", "Seller", "Driver"].sample,
        state: Faker::Boolean.boolean(0.9)
      )
    rescue StandardError => e
      puts "Error found #{e.to_s}"
    end
  end
end

puts "Seeding prodivers"
40.times do |count|
  begin
    Provider.create(
      id: (count + 1),
      name: Faker::Company.name,
      FEIN: "#{Faker::Number.number(2)}-#{Faker::Number.number(7)}",
      phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}",
      email: Faker::Internet.email,
      address: "#{Faker::Address.street_address}. #{Faker::Address.city}, #{Faker::Address.state} #{Faker::Address.zip_code}",
      state: Faker::Boolean.boolean(0.9)
    )
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

puts "Seeding categories"

categories_list = [["Anise", "Anís"], ["Apples", "Manzanas"], ["Artichokes", "Alcachofas"], ["Asparagus", "Esparragos"], ["Bananas", "Bananas"], ["Beans", "Frijoles"], ["Berries", "Bayas"], ["Carrots", "Zanahorias"], ["Dried Chiles", "Chiles Secos"], ["Fresh Chiles", "Chiles Frescos"], ["Lettuce", "Lechugas"], ["Asian Specialties", "Especialidades Asiáticas"], ["Specialty Fruits", "Frutas Especiales"], ["Specialty Vegetables", "Vegetales Especiales"]]

count = 0

categories_list.each do |name, name_spanish|
  begin
    Category.create(
      id: (count + 1),
      name: name,
      name_spanish: name_spanish,
      description: Faker::Food.description,
      description_spanish: Faker::Food.description,
    )
    count += 1
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

puts "Seeding products"
120.times do |count|
  begin
    Product.create(
      id: (count + 1),
      name: Faker::Food.dish,
      name_spanish: Faker::Food.dish,
      barcode: Faker::Code.ean,
      price: Faker::Number.decimal(4, 2),
      content: Faker::Food.measurement,
      content_spanish: Faker::Food.measurement,
      description: Faker::Food.description,
      description_spanish: Faker::Food.description,
      recipes: "#{Faker::Food.dish}, #{Faker::Food.dish}, #{Faker::Food.dish}",
      recipes_spanish: "#{Faker::Food.dish}, #{Faker::Food.dish}, #{Faker::Food.dish}",
      state: Faker::Boolean.boolean(0.8),
      category_id: Faker::Number.between(1, 5)
    )
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

puts "Seeding customers"
80.times do |count|
  begin
    Customer.create(
      id: (count + 1),
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      company: Faker::Company.name,
      email: Faker::Internet.email,
      phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}",
      zipcode: Faker::Address.zip_code,
      address: "#{Faker::Address.street_address}. #{Faker::Address.city}, #{Faker::Address.state}",
      state: Faker::Boolean.boolean(0.8)
    )
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

puts "Seeding users"
# SOON


puts "Seeding purchase orders"
580.times do |count|
  begin
    Purchase.create(
      id: (count + 1),
      purchase_datetime: Faker::Date.between(1.years.ago, Date.today),
      receipt_number: "N/A",
      status: "ordered",
      discount: Faker::Number.between(1, 10),
      provider_id: Faker::Number.between(1, 35),
      employee_id: Faker::Number.between(1, 15),
      observations: "",
      state: Faker::Boolean.boolean(0.95)
    )
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

puts "Seeding purchase details"
2500.times do |count|
  begin
    PurchaseDetail.create(
      id: (count + 1),
      purchase_id: Faker::Number.between(1, 560),
      product_id: Faker::Number.between(1, 110),
      price: Faker::Number.decimal(4, 2),
      quantity: Faker::Number.between(1, 100),
      status: "ordered"
      # status: ["ordered", "returned"].sample
    )
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

puts "The information have been seeded"

# rails db:drop
# rails db:create
# rails db:migrate
# rails db:seed
# rails s
