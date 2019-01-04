json.id product.id
json.name product.name
json.name_spanish product.name_spanish
json.barcode product.barcode
json.price product.price
# json.content product.content
# json.content_spanish product.content_spanish
# json.description product.description
# json.description_spanish product.description_spanish
# json.recipes product.recipes
# json.recipes_spanish product.recipes_spanish
json.state product.state
json.slug product.slug
# json.created_at product.created_at
# json.updated_at product.updated_at
json.category_id product.category_id
json.image_url product.image.attached? ? url_for(product.image) : "https://s3.amazonaws.com/betterandnice/images/default/product-default.png"
