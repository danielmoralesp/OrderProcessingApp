class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :process_order, :complete_order, :fail_order, :cancel_order]

  def index
    @orders = Order.all
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      redirect_to @order, notice: "Order created successfully"
    else
      render :new
    end
  end

  def show
  end

  def process_order
    @order.update_status(:process)
    redirect_to @order, notice: "Order is now processing."
  end

  def complete_order
    @order.update_status(:complete)
    redirect_to @order, notice: "Order has been completed."
  end

  def fail_order
    @order.update_status(:fail)
    redirect_to @order, notice: "Order has failed."
  end

  def cancel_order
    @order.update_status(:cancel)
    redirect_to @order, notice: "Order has been canceled."
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:user_id)
  end
end