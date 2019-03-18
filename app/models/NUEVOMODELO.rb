# Update product stock on create
def update_stock_create
  product = Product.find(self.product_id) || nil

  # If product has been found
  if product

    # If is not a return
    if self.status != "returned"
      # Current stock - Sale quantity
      final_stock = product.stock - self.quantity

      # If the sale quantity exceed the stock
      if (final_stock) < 0
        self.errors.add(:quantity, I18n.t("sale.stock_is_less_sale", stock: product.stock, product: I18n.locale == :es ? product.name_spanish : product.name))
        return

        #  If the sale quantity is less than the stock
      else
        # Set new stock to product
        product.stock = final_stock

        # Saving product new stock
        if product.save
          puts "Product stock updated on sale detail create"

          # Product stock not saved
        else
          puts "Product stock not updated on sale detail create"
        end
        # End Saving product new stock
      end
      # End If product stock is less than the quantity to sale
    end
    # End If is not a return
  end
  # End If product has been found
end
# End Update product stock on create
