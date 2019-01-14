# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Form
Rails.application.config.assets.precompile += %w( form.js )

# Jquery Mask
Rails.application.config.assets.precompile += %w( jquery-mask/jquery.mask.js )

# Clickeable Row
Rails.application.config.assets.precompile += %w( clickable-row.js )

# Select Category
Rails.application.config.assets.precompile += %w( select-category.js )

# PDF
Rails.application.config.assets.precompile += %w( admin/application.scss )

# Material input
Rails.application.config.assets.precompile += %w( material-input.js )

# Pagination with Ajax
Rails.application.config.assets.precompile += %w( pagination-ajax.js )

# Auto search
Rails.application.config.assets.precompile += %w( auto-search.js )

# Display password
Rails.application.config.assets.precompile += %w( display-password.js )

# Admin
Rails.application.config.assets.precompile += %w( admin.scss )

# Landing
Rails.application.config.assets.precompile += %w( landing.scss )

# Landing
Rails.application.config.assets.precompile += %w( landing.js )

# E-commerce
Rails.application.config.assets.precompile += %w( ecommerce.css )

# E-commerce
Rails.application.config.assets.precompile += %w( ecommerce.js )

# Add to Cart
Rails.application.config.assets.precompile += %w( cart.js )

# Notifications
Rails.application.config.assets.precompile += %w( notifications.js )

# Barcode
Rails.application.config.assets.precompile += %w( barcode.js )
