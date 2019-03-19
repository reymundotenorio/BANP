# Update product stock on update
def update_stock
  product = Product.find(self.product_id) || nil

  # If product has been found
  if product
    # If sale is active
    if self.sale.state
      old_quantity = self.changes["quantity"][0] if changes["quantity"]
      old_quantity = 0 if !old_quantity

      old_status = self.changes["status"][0] if changes["status"]
      old_status = "invoiced" if !old_status

      # If is an invoice or a delivery
      if (self.status == "invoiced" || self.status == "delivered")
        # Current stock - Old Sale quantity + New Sale quantity
        final_stock =  product.stock + old_quantity - self.quantity

        # If the new quantity exceed the stock
        if final_stock < 0
          self.errors.add(:quantity, I18n.t("sale.stock_is_less_sale", stock: product.stock, product: I18n.locale == :es ? product.name_spanish : product.name))
          return

          # If the new quantity is less than the stock
        else
          # Set new stock to product
          product.stock = final_stock

          # If quantity was reduced
          if self.quantity <= old_quantity
            # Save new return
            returned = SaleDetail.new
            returned.sale_id = self.sale_id
            returned.product_id = self.product_id
            returned.price = self.price
            returned.quantity = self.quantity
            returned.status = "returned"

            # Reset params
            self.quantity = (old_quantity - self.quantity)

            # Saving return
            if returned.save
              puts "Return created on sale detail update"

              # Return not saved
            else
              puts "Return not created on sale detail update"
            end
            # End Saving return

            # If quantity was not reduced
          else
            # Quantity to return is more than the quantity sold
            self.errors.add(:quantity, I18n.t("sale.quantity_more_than_sold", quantity: self.quantity, product: I18n.locale == :es ? product.name_spanish : product.name))
            return
          end
          # End If quantity was reduced

          # Saving product new stock
          if product.save
            puts "Product stock updated on sale detail update"

            # Product stock not saved
          else
            puts "Product stock not updated on sale detail update"
          end
          # End Saving product new stock
        end
        # End If the new quantity exceed the stock
      end
      # End If is an invoice or a delivery
    end
    # End If sale is active
  end
  # End If product has been found
end
# End Update product stock on update
