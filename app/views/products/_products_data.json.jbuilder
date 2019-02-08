json.id product.id
json.name product.name
json.name_spanish product.name_spanish
json.barcode product.barcode
json.price product.price
json.image_url product.image.attached? ? url_for(product.image) : "https://s3.amazonaws.com/betterandnice/images/default/product-default.png"
