class PaymentsController < ApplicationController

  def new
    @user = user
    product = Stripe::Product.retrieve('prod_QCCrNXeyMcBLdS')
    price = Stripe::Price.retrieve(product.default_price)
    @currency = price.currency == 'usd' ? '$' : nil
    @price = price.unit_amount
  end
  
  def create
    current_user = user

    #create stripe customer for payment, update if already created
    customer = Stripe::Customer.create({
      name: current_user.full_name,
      :email => params[:stripeEmail],
      description: "Customer id: #{current_user.id}",
      :source => params[:stripeToken]
    })

    Stripe::Subscription.create({
      customer: customer,
      items: [{price: ENV["STRIPE_SUBSCRIPTION_ID"]}],
    })
    redirect_to root_url, notice: "Purchase Successful"

  end

  def user
    OpenStruct.new(
      id: 173,
      full_name: 'Juancito de los palotes',
      email: 'juandev@gmail.com'
    )
  end

  def success
    #handle successful payments
    redirect_to root_url, notice: "Purchase Successful"
  end

  def cancel
    #handle if the payment is cancelled
    redirect_to root_url, notice: "Purchase Unsuccessful"
  end

end