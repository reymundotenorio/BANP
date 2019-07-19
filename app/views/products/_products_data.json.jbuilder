json.id product.id
json.name product.name
json.name_spanish product.name_spanish
json.barcode product.barcode
json.price product.price
json.image_url product.image.attached? ? url_for(product.image) : "https://res.cloudinary.com/reymundotenorio/image/upload/v1563543090/BANP/product-arkansas-black-apple.png"
