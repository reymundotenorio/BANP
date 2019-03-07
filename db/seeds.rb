# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# password_digest: "$2a$10$QNH5ak1i2KhPV9Be5sVWfeceogykeeMfW6yaxvtcDjt50viG/2ekC"

require "faker"

puts "Seeding employees"

employee_count = 1

# SIBANP
Employee.create(id: (employee_count), first_name: "- SIBANP", last_name: "-", email: "admin@betterandnice.com", phone: "(305) 557-3700", role: "administrator", state: true)
employee_count += 1

# Administrator
Employee.create( id: (employee_count), first_name: "José", last_name: "Altamirano", email: "reymundotenorio@outlook.com", phone: "+50588070840", role: "administrator", state: true)
employee_count += 1

# Chief dispatch
Employee.create( id: (employee_count), first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email:  Faker::Internet.email, phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}", role: "chief_dispatch", state: true)
employee_count += 1

# Warehouse supervisor
Employee.create( id: (employee_count), first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email:  Faker::Internet.email, phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}", role: "warehouse_supervisor", state: true)
employee_count += 1

# Warehouse assistant
Employee.create( id: (employee_count), first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email:  Faker::Internet.email, phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}", role: "warehouse_assistant", state: true)
employee_count += 1

# Warehouse assistant
Employee.create( id: (employee_count), first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email:  Faker::Internet.email, phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}", role: "warehouse_assistant", state: true)
employee_count += 1

# Sales agent
Employee.create( id: (employee_count), first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email:  Faker::Internet.email, phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}", role: "seller", state: true)
employee_count += 1

# Sales agent
Employee.create( id: (employee_count), first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email:  Faker::Internet.email, phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}", role: "seller", state: true)
employee_count += 1

# Drivers
Employee.create( id: (employee_count), first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email:  Faker::Internet.email, phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}", role: "driver", state: true)
employee_count += 1

# Drivers
Employee.create( id: (employee_count), first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email:  Faker::Internet.email, phone: "(#{Faker::Number.number(3)}) #{Faker::Number.number(3)}-#{Faker::Number.number(4)}", role: "driver", state: true)
employee_count += 1

puts "Seeding users"
begin
  User.create(id: 1, employee_id: 2, email: "reymundotenorio@outlook.com", password_digest: "$2a$10$QNH5ak1i2KhPV9Be5sVWfeceogykeeMfW6yaxvtcDjt50viG/2ekC", confirmed: true, two_factor_auth: false).save(validate: false)
rescue StandardError => e
  puts "Error found #{e.to_s}"
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

categories_id = Array.new

Category.enabled.each do |category|
  categories_id.push(category.id)
end

puts "Seeding products"

product_count = 1

Product.create(
  id: (product_count),
  name: "Pepino",
  name_spanish: "Pepino",
  price: 18.00,
  category_id: 14,
  content: "40 lbs",
  content_spanish: "40 lbs",
  description: "The cucumber is a summer vegetable, elongated and about 15cm long. Its skin is green that lightens until it turns yellow at maturity.",
  description_spanish: "El pepino es una hortaliza de verano, de forma alargada y de unos 15cm de largo. Su piel es de color verde que se aclara hasta volverse amarilla en la madurez.",
  recipes: "Cucumber snacks with roasted shrimp, Cucumber sushi, Thai salad, Stuffed cucumber, Bites of cucumber with salmon.",
  recipes_spanish: "Botanas de pepino con camarones asados, Sushi de pepino, Ensalada Thai, Pepino relleno, Bites de pepino con salmón.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Green chiltoma",
  name_spanish: "Chiltoma verde",
  price: 14.00,
  category_id: 10,
  content: "144 units",
  content_spanish: "144 unidades",
  description: "Chiltoma belongs to the Solanaceae family. It is an important vegetable for its nutritional value. It is rich in vitamins A, B1, B2 and C.",
  description_spanish: "La chiltoma pertenece a la familia Solanaceae. Es una hortaliza importante por su valor nutritivo. Es rica en vitaminas A, B1, B2 y C.",
  recipes: "Stuffed chiltoma, fusilli, brochettes, chiltoma omelette, roasted chiltoma.",
  recipes_spanish: "Chiltoma rellenas, fusilli, brochetas, omelette de chiltoma, chiltoma asada.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Red chiltoma",
  name_spanish: "Chiltoma roja",
  price: 22.00,
  category_id: 10,
  content: "144 units",
  content_spanish: "144 unidades",
  description: "Chiltoma belongs to the Solanaceae family. It is an important vegetable for its nutritional value. It is rich in vitamins A, B1, B2 and C.",
  description_spanish: "La chiltoma pertenece a la familia Solanaceae. Es una hortaliza importante por su valor nutritivo. Es rica en vitaminas A, B1, B2 y C.",
  recipes: "Stuffed chiltoma, fusilli, brochettes, chiltoma omelette, roasted chiltoma.",
  recipes_spanish: "Chiltoma rellenas, fusilli, brochetas, omelette de chiltoma, chiltoma asada.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Tomato 5x6",
  name_spanish: "Tomate 5x6",
  price: 18.50,
  category_id: 13,
  content: "25 lbs",
  content_spanish: "25 lbs",
  description: "It is a fruit of the species of herbaceous plant of the genus Solanum of the family Solanaceae; It is native to Central and South America and its use as food would have originated in Mexico about 2500 years ago.",
  description_spanish: "Es una fruta de la especie de planta herbácea del género Solanum de la familia Solanaceae; es nativa de Centro y Sudamérica y su uso como comida se habría originado en México hace unos 2500 años.​",
  recipes: "Cold tomato soup, tuna with tomato, tomato and mozzarella salad, lasagna.",
  recipes_spanish: "Sopa fría de tomate, atún con tomate, ensalada de tomate y mozzrela, lasaña.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "California lettuce",
  name_spanish: "Lechuga California",
  price: 22.00,
  category_id: 11,
  content: "24 units",
  content_spanish: "24 unidades",
  description: "This variety of lettuce is consumed throughout the world and is characterized by its mild and watery taste.",
  description_spanish: "Esta variedad de lechuga es consumida en todo el mundo y se caracteriza por su sabor suave y acuoso.",
  recipes: "Green salad, watermelon brochette with ham and lettuce, Banana salad New York.",
  recipes_spanish: "Ensalada verde, Brocheta de sandía con jamon y lechuga, Ensalada de plátano New York.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Pineapple",
  name_spanish: "Piña",
  price: 14.75,
  category_id: 13,
  content: "6 units",
  content_spanish: "6 unidades",
  description: "The tropical pineapple or pineapple is the fruit obtained from the plant that receives the same name. Its shape is oval and thick, approximately 30 cm long and 15 cm in diameter.",
  description_spanish: "La piña tropical o piña americana es la fruta obtenida de la planta que recibe el mismo nombre. Su forma es ovalada y gruesa, con aproximadamente 30 cm de largo y 15 cm de diámetro.",
  recipes: "Pineapple and carrot smoothie, Wellington Cocktail, Apple and tropical fruit salad, Pineapple and blue cheese sauce with crispy vegetables.",
  recipes_spanish: "Batido de piña y zanahorias, Cocktail Wellington, Ensalada de manzana y frutas tropicales, Salsa de piña y queso azul con hortalizas crujientes.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "California orange",
  name_spanish: "Naranja california",
  price: 26.75,
  category_id: 13,
  content: "88 units",
  content_spanish: "88 unidades",
  description: "The California Oranges, has among its main characteristics a very sweet flavor, besides being juicy, they do not have seeds, and very easy to peel.",
  description_spanish: "Las Naranjas California, tiene entre sus características principales un sabor muy dulce, además de ser jugosas, no tienen semillas, y muy fáciles de pelar.",
  recipes: "Peach and orange smoothie, Crab with orange, Wellington cocktail, Tropical fruit salad, Floating banana and orange islands, Orange loin, Fruit punch.",
  recipes_spanish: "Batido de melocotón y naranja, Cangrejo a la naranja, Cocktaill Wellington, Ensalada de fruta tropical, Islas flotantes de plátano y naranja, Lomo a la naranja, Ponche de frutas.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Honeydew Cantaloupe",
  name_spanish: "Melón rocío de miel",
  price: 23.50,
  category_id: 13,
  content: "6 units",
  content_spanish: "6 unidades",
  description: "It is a fruit of the melon family that is grown for gastronomic consumption. The fruit is similar to orange melon but has a sweeter flavor, contains more water and has a pale or light green color.",
  description_spanish: "Es un fruto de la familia de melones que se cultiva para el consumo gastronómico. La fruta es similar al melón anaranjado pero tiene un sabor más dulce, contiene más agua y posee un color verde pálido o claro.",
  recipes: "Melon with wine, melon sangria, tomato and melon skewers.",
  recipes_spanish: "Melón con vino, sangría de melon, Pinchos de Tomate y melón.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Cantaloupe",
  name_spanish: "Melón",
  price: 19.75,
  category_id: 13,
  content: "9 units",
  content_spanish: "9 unidades",
  description: "The melon is a globose fruit, round or elongated, 20 to 30cm long and up to 2kg in weight. The crushed or reticulated bark can be light yellow, green or combinations of both depending on the variety, the pulp is aromatic, juicy and sweet, can be white or greenish white, yellow and orange. Inside it has numerous nuggets with yellow rind.",
  description_spanish: "El melón es una fruta globosa, redonda o alargada, de 20 a 30cm de largo y hasta 2kg de peso. La corteza surcada o reticulada puede ser de color amarillo claro, verde o combinaciones de ambos según la variedad, la pulpa es aromática, jugosa y dulce, puede ser blanca o blanca verdosa, amarilla y anaranjada. Dentro tiene numerosas pepitas con cáscara amarilla.",
  recipes: "Apple and tropical fruit salad, banana, melon and grapefruit salad, ice-cold fruit skewers, melon and strawberry puree, timbales with scarlet sauce.",
  recipes_spanish: "Ensalada de manzana y frutas tropicales, Ensalada de plátano, melón y pomelo, Pinchitos de fruta helada, puré de melón y fresa, Timbales con salsa escarlata.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Washington Red Apple",
  name_spanish: "Manzana roja Whasington",
  price: 33.75,
  category_id: 14,
  content: "72 units",
  content_spanish: "72 unidades",
  description: "An important difference between the qualities of Washington and those of the United States in red varieties is the definition and interpretation of 'good red tone'. The qualities of Washington demand a red tone more uniform, intense and deep than those of the United States.",
  description_spanish: "Una diferencia importante entre las calidades de Washington y las de los Estados Unidos en las variedades rojas es la definición e interpretación del “buen tono rojo”. Las calidades de Washington exigen un tono rojo más uniforme, intenso y profundo que las de los Estados Unidos.",
  recipes: "Apple Pie, Apple Salad and Tropical Fruits, Lancashire Stew, Apple Strudel.",
  recipes_spanish: "Pastel de manzana, Ensalada de manzana y frutas tropicales, Estofado Lancashire, Strudel de manzana.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Chopped lettuce",
  name_spanish: "Lechuga picada",
  price: 21.50,
  category_id: 11,
  content: "20 lbs",
  content_spanish: "20 lbs",
  description: "This variety of lettuce is consumed throughout the world and is characterized by its mild and watery taste.",
  description_spanish: "Esta variedad de lechuga es consumida en todo el mundo y se caracteriza por su sabor suave y acuoso.",
  recipes: "Green salad, watermelon brochette with ham and lettuce, Banana salad New York.",
  recipes_spanish: "Ensalada verde, Brocheta de sandía con jamon y lechuga, Ensalada de plátano New York.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Zucchini",
  name_spanish: "Zucchini",
  price: 13.50,
  category_id: 12,
  content: "18 lbs",
  content_spanish: "18 lbs",
  description: "It is a summer squash that can reach almost 1 meter in length, but it is usually harvested when it is still immature at about 15 to 25 cm.",
  description_spanish: "Es una calabaza de verano que puede alcanzar casi 1 metro de longitud, pero generalmente se cosecha cuando aún está inmadura a unos 15 a 25 cm.",
  recipes: "Vegetable quiche, fried zucchini sticks, zucchini soup, oriental chicken.",
  recipes_spanish: "Quiche de verdura, Palitos de zucchini fritos, Sopa de zucchini, Pollo a la oriental.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Haas Avocado",
  name_spanish: "Aguacate Haas",
  price: 28.50,
  category_id: 13,
  content: "48 units",
  content_spanish: "48 unidades",
  description: "With a hazelnut flavor. It has yellow flesh, is small, rough and dark skin.",
  description_spanish: "Con sabor a avellana. Tiene la pulpa amarilla, es pequeño, rugoso y de piel oscura.",
  recipes: "Avocado with onions and salsa, avocado salad, avocado vegetable tacos, cod with tomato, prawns and avocado.",
  recipes_spanish: "Aguacate con cebollas y salsa, Ensalada de aguacate, Tacos vegetales de aguacate, Bacalao con tomate, gambas y aguacate.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Maroon Carrot",
  name_spanish: "Zanahoria Marrón",
  price: 26.50,
  category_id: 8,
  content: "50 lbs",
  content_spanish: "50 lbs",
  description: "The carrot is rich in carotene, a precursor substance of vitamin A, necessary in the growth, development of bones, sight, maintenance of tissues, reproduction and in the hormonal system. In addition, it is believed to prevent against cancer, apart from being a food rich in fiber and low in calories.",
  description_spanish: "La zanahoria es rica en caroteno, sustancia precursora de la vitamina A, necesaria en el crecimiento, desarrollo de huesos, vista, mantenimiento de los tejidos, reproducción y en el sistema hormonal. Además, se cree que previene contra el cáncer, aparte de ser un alimento rico en fibra y bajo en calorías.",
  recipes: "Banana salad New York, Salad with carrots and bananas, Vegetable paella, Vegetable cake, Carrot soup and orange.",
  recipes_spanish: "Ensalada de plátano New York, Ensalada de zanahorias y plátanos, Paella vegetal, Pastel de verduras, Sopa de zanahoria y naranja.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Red grape",
  name_spanish: "Uva roja",
  price: 29.75,
  category_id: 13,
  content: "20 lbs",
  content_spanish: "20 lbs",
  description: "This fruit is characterized by its sweet flavor because it is rich in water and sugar. This high index of sugars are of immediate assimilation and therefore make their digestion easy.",
  description_spanish: "Esta fruta se caracteriza por su dulce sabor debido a que es rica en agua y azúcar. Este elevado índice de azúcares son de asimilación inmediata y por lo tanto hacen fácil su digestión.",
  recipes: "Banana and grape smoothie, celery and grapes salad, grape ice cream, fruit soup, cream grapes, cheesecake with grapes and nuts.",
  recipes_spanish: "Batido de plátano y uva, Ensalada de apio y uvas, Helado de uva, Sopa de frutas, Uvas a la crema, Tarta de queso con uva y nueces.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "White grape",
  name_spanish: "Uva blanca",
  price: 29.50,
  category_id: 13,
  content: "20 lbs",
  content_spanish: "20 lbs",
  description: "The white grape combines its low caloric level with interesting amounts of fiber, vitamins and minerals, among other components.",
  description_spanish: "La uva blanca combina su bajo nivel calórico con unas interesantes cantidades de fibra, vitaminas y minerales, entre otros componentes.",
  recipes: "Chicken with white grapes, Banana and grape smoothie, Celery and grapes salad, Grape ice cream, Fruit soup, Cream grapes, Cheesecake with grapes and nuts.",
  recipes_spanish: "Pollo con uvas blancas, Batido de plátano y uva, Ensalada de apio y uvas, Helado de uva, Sopa de frutas, Uvas a la crema, Tarta de queso con uva y nueces.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Fresa California",
  name_spanish: "California Strawberry",
  price: 18.50,
  category_id: 7,
  content: "12 lbs",
  content_spanish: "12 lbs",
  description: "Strawberries are very appreciated for their pleasant aroma and stimulating appetite effect. They are easily digestible and have a great laxative effect due to their fiber, pigments, acids and enzymes. Its richness in basic minerals gives it the property of stimulating the metabolism.",
  description_spanish: "Las fresas son muy apreciadas por su agradable aroma y efecto estimulante del apetito. Son fácilmente digestibles y tienen un gran efecto laxante debido a su fibra, pigmentos, ácidos y enzimas. Su riqueza en minerales básicos le confiere la propiedad de estimular el metabolismo.",
  recipes: "Strawberry milkshake, strawberry chutney, tropical Macedonia, melon and strawberry puree, strawberry soup.",
  recipes_spanish: "Batido de fresa, chutney de fresa, Macedonia tropical, Puré de melón y fresa, Suflé de fresa.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

Product.create(
  id: (product_count),
  name: "Kiwi",
  name_spanish: "Kiwi",
  price: 28.50,
  category_id: 13,
  content: "15 lbs",
  content_spanish: "15 lbs",
  description: "Various scientific researches indicate that the kiwi is an outstanding source of vitamins, minerals, fiber and phytochemicals. The kiwi has an exceptionally high concentration of vitamin C.",
  description_spanish: "Diversas investigaciones científicas indican que el kiwi es una destacada fuente de vitaminas, minerales, fibra y fitoquímicos. El kiwi posee una concentración excepcionalmente alta de vitamina C.",
  recipes: "Avocado with kiwis, Kiwi milkshake, Kiwi and ginger ale cocktail, Wellington Cocktail, Kiwi and caviar, Sushi rolls with kiwi.",
  recipes_spanish: "Aguacate con kiwis, Batido kiwiana, Cocktail de kiwi y ginger ale, Cocktaill Wellington, Kiwi y caviar, Rollos de sushi con kiwi.",
  barcode: Faker::Code.ean,
  state: true
)
product_count += 1

60.times do |count|
  begin
    product_count += 1
    Product.create(
      id: (product_count),
      name: Faker::Food.dish,
      name_spanish: Faker::Food.dish,
      barcode: Faker::Code.ean,
      price: Faker::Number.decimal(2, 2).to_d.abs,
      content: Faker::Food.measurement,
      content_spanish: Faker::Food.measurement,
      description: Faker::Food.description,
      description_spanish: Faker::Food.description,
      recipes: "#{Faker::Food.dish}, #{Faker::Food.dish}, #{Faker::Food.dish}",
      recipes_spanish: "#{Faker::Food.dish}, #{Faker::Food.dish}, #{Faker::Food.dish}",
      state: Faker::Boolean.boolean(0.8),
      category_id: categories_id.sample
    )

  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

puts "Seeding customers"
80.times do |count|

  if count == 0 # Creating Independent customer
    Customer.create(
      id: (count + 1),
      first_name: "***",
      last_name: "***",
      company: "***",
      email: "***@***.***",
      phone: "(***) ***-****",
      zipcode: "***",
      address: "***",
      state: true
    )

  else
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
end

providers_id = Array.new

Provider.enabled.each do |provider|
  providers_id.push(provider.id)
end

employees_id = Array.new

Employee.enabled.each do |employee|
  employees_id.push(employee.id)
end

puts "Seeding purchase orders"
5600.times do |count|
  begin
    Purchase.create(
      id: (count + 1),
      purchase_datetime: Faker::Date.between(1.years.ago, Date.today),
      receipt_number: "N/A",
      status: "ordered",
      discount: Faker::Number.between(1, 10),
      provider_id: providers_id.sample,
      employee_id: employees_id.sample,
      observations: "",
      state: Faker::Boolean.boolean(0.95)
    )
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

products_id = Array.new

Product.enabled.each do |product|
  products_id.push(product.id)
end

purchases_id = Array.new

Purchase.enabled.each do |purchase|
  purchases_id.push(purchase.id)
end

puts "Seeding purchase details"
10300.times do |count|
  begin
    PurchaseDetail.create(
      id: (count + 1),
      purchase_id: purchases_id.sample,
      product_id: products_id.sample,
      price: Faker::Number.decimal(2, 2).to_d.abs,
      quantity: Faker::Number.between(1, 100),
      status: "ordered"
      # status: ["ordered", "returned"].sample
    )
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

customers_id = Array.new

Customer.enabled.each do |customer|
  customers_id.push(customer.id)
end

puts "Seeding sale invoices"
5600.times do |count|
  begin
    Sale.create(
      id: (count + 1),
      sale_datetime: Faker::Date.between(1.years.ago, Date.today),
      delivery_status: "delivered",
      payment_method: "cash",
      payment_reference: "-",
      paid: Faker::Boolean.boolean(0.95),
      status: "invoiced",
      discount: Faker::Number.between(1, 10),
      customer_id: customers_id.sample,
      employee_id: employees_id.sample,
      observations: "",
      state: Faker::Boolean.boolean(0.95)
    )
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

sales_id = Array.new

Sale.enabled.each do |sale|
  sales_id.push(sale.id)
end

puts "Seeding sale details"
10300.times do |count|
  begin
    SaleDetail.create(
      id: (count + 1),
      sale_id: sales_id.sample,
      product_id: products_id.sample,
      price: Faker::Number.decimal(2, 2).to_d.abs,
      quantity: Faker::Number.between(1, 100),
      status: "invoiced"
    ).save(validate: false)
  rescue StandardError => e
    puts "Error found #{e.to_s}"
  end
end

# puts "Products ids: #{products_id}"
puts "The information have been seeded"

# rails db:drop
# rails db:create
# rails db:migrate
# rails db:seed
# rails s
