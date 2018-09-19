require 'pry'

#takes a cart array and transforms to a Hash
#adds property 'count' for duplicate items
def consolidate_cart(cart)
  consolidated = {}
  cart.each {|c_item|
    c_item.each {|key,properties|
      if !consolidated.keys.include?(key)
        consolidated[key] = properties
        consolidated[key][:count] = cart.select{|i|
          c_item == i
        }.length
      end
    }
  }
  consolidated
end

#takes a cart hash and array of coupons
#returns a new hash with coupons applied to cart
def apply_coupons(cart, coupons)
  cart_with_coupons = {}
  cart.each{|item,properties| #each item in cart hash
    cart_with_coupons[item] = properties #add properties to new hash
    coupons.each{|coupon| #each coupon in coupon array
      if item == coupon[:item]
        #check if 'minimum amount' met: coupon cost (total) less than price of item * number of items
        if coupon[:cost] < (cart_with_coupons[item][:price] * cart_with_coupons[item][:count])
          #check how many items the coupon will apply to and update that item's count
          if coupon[:num] > cart_with_coupons[item][:count]
            cart_with_coupons[item][:count] = 0
          else
            cart_with_coupons[item][:count] -= coupon[:num] #decrement item count_elements
          end

          #check if item with coupon is already in cart
          if cart_with_coupons.has_key?("#{item} W/COUPON") #check if coupon already exists in cart
            cart_with_coupons["#{item} W/COUPON"][:count] += 1 #increment
          else
            cart_with_coupons["#{item} W/COUPON"] = {
              price: coupon[:cost],
              clearance: cart_with_coupons[item][:clearance],
              count: 1
            }
          end
        end
      end
    }
  }

  cart_with_coupons
end

#takes cart as hash
def apply_clearance(cart)
  cart.collect{|item,properties|
    if properties[:clearance] == true
      properties[:price] = (properties[:price] * 0.8).round(2)
    end
  }
  cart
end

#helper function to add up cart total
#takes cart as hash
def get_cart_total(cart)
  total = 0
  cart.each {|item,properties|
    total += (properties[:price] * properties[:count])
  }
  total
end

def checkout(cart, coupons)
  consolidated_cart = consolidate_cart(cart)
  cart_with_coupons = apply_coupons(consolidated_cart, coupons)
  cart_with_clearance = apply_clearance(cart_with_coupons)
  total = get_cart_total(cart_with_clearance)
  if total > 100
    total = (total * 0.9).round(2)
  end
  total
end
