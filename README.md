# README

Rails application with a use case for the `OrchestrateFlow` gem, let's simulate a more complete e-commerce **Order Processing Workflow**. This setup will include `new` and `create` actions, along with controller logic and views to handle order creation and workflow transitions.

## Order Processing Workflow
In this Rails application, the order workflow goes through these steps:

1. States: Orders progress through states like `created`, `processing`, `completed`, `failed`, and `canceled`.
2. Transitions: We’ll define transitions based on user actions such as `process`, `complete`, `fail`, and `cancel`.
3. Event Actions: Each transition will trigger a specific action, like notifying users or updating inventory.
Implementation


## Implementation
1. Set Up the Rails Application and Install the Gem

```bash
rails new OrderProcessingApp
cd OrderProcessingApp
```

2. Add Gem

```Gemfile
# OrchestrateFlow gem for managing orchestration tasks and actions
gem 'orchestrate_flow'
```

```bash
# Install dependencies
bundle install
```

3. Generate the Order Model and Migration
Create an `Order` model with attributes to store information about each order and its workflow status.

```bash
rails generate model Order user_id:integer status:string
rails db:migrate
```

4. Define the Order Workflow with `OrchestrateFlow`
Create a custom workflow class to manage the states and transitions of an order. Each transition will have associated actions.

`app/models/order_workflow.rb`

```ruby

require "orchestrate_flow"

class OrderWorkflow < OrchestrateFlow::Workflow
  def initialize(state: :created) # Accept initial state as an argument
    super()
    @state = state
  end
  
  state :created
  state :processing
  state :completed
  state :failed
  state :canceled

  # Define transitions between states
  transition event: :process, from: :created, to: :processing
  transition event: :complete, from: :processing, to: :completed
  transition event: :fail, from: :processing, to: :failed
  transition event: :cancel, from: :created, to: :canceled

  # Event-driven actions
  on :process do
    puts "Order is being processed."
    # Simulate inventory update, for example
  end

  on :complete do
    puts "Order completed sucessfully!"
    # Send a notification, e.g., OrderMailer.notify_completion(order)
  end

  on :fail do
    puts "Order processing failed. Notifying support."
    # Notify support team
  end

  on :cancel do
    puts "Order has been canceled."
    # Refund payment or update inventory
  end
end
```

5. Update the `Order` Model to Use the Workflow
Connect the `Order` model to the workflow class so that it can manage the state transitions.

`app/models/order.rb`

```ruby

class Order < ApplicationRecord
  after_initialize :set_initial_status

  # Initializes the workflow for the order
  def workflow
    @workflow ||= OrderWorkflow.new(state: status.to_sym) # Initialize workflow with current state
  end

  # Set initial status to `created` when a new order is initialized
  def set_initial_status
    self.status ||= "created"
  end

  # Sync's the model status with the workflow's state
  def update_status(event)
    workflow.trigger(event)
    self.status = workflow.state.to_s
    save!
  end
end

```

6. Create the Orders Controller
Define the `OrdersController` to handle order creation and transitions. This includes `new`, `create`, and `transition` actions.

`app/controllers/orders_controller.rb`

```ruby
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
```

7. Define Routes
Add routes for each transition as well as the basic `new`, `create`, and `show` actions.

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :orders do
    member do 
      patch :process_order
      patch :complete_order
      patch :fail_order
      patch :cancel_order
    end
  end

  root "orders#index"
end
```

8. Create Views for Orders

`app/views/orders/new.html.erb`
A form for creating a new order.

```html
<%= form_with model: @order, local: true do |form| %>
  <p>
    <%= form.label :user_id %>
    <%= form.number_field :user_id %>
  </p>
  <p>
    <%= form.submit "Create Order" %>
  </p>
<% end %>
<%= link_to 'Back to Orders', orders_path %>
```

`app/views/orders/index.html.erb`
List all orders with links to view and transition actions.

```html
<h1>Orders</h1>

<%= link_to 'New Order', new_order_path %>

<table>
  <tr>
    <th>ID</th>
    <th>Status</th>
    <th>Actions</th>
  </tr>

  <% @orders.each do |order| %>
    <tr>
      <td><%= link_to order.id, order_path(order) %></td>
      <td><%= order.status %></td>
      <td>
        <%= button_to 'Process', process_order_order_path(order), method: :patch %>
        <%= button_to 'Complete', complete_order_order_path(order), method: :patch %>
        <%= button_to 'Fail', fail_order_order_path(order), method: :patch %>
        <%= button_to 'Cancel', cancel_order_order_path(order), method: :patch %>
      </td>
    </tr>
  <% end %>
</table>
```

`app/views/orders/show.html.erb`
Display individual order details with transition links.

```html
<h1>Order #<%= @order.id %></h1>

<p>Status: <%= @order.status %></p>

<p>
  <%= button_to 'Process', process_order_order_path(@order), method: :patch %>
  <%= button_to 'Complete', complete_order_order_path(@order), method: :patch %>
  <%= button_to 'Fail', fail_order_order_path(@order), method: :patch %>
  <%= button_to 'Cancel', cancel_order_order_path(@order), method: :patch %>
</p>

<%= link_to 'Back to Orders', orders_path %>

```

## Testing the Workflow
Start the Rails server and visit the app to create and manage orders:

```bash
rails server
```


1. Navigate to `http://localhost:3000/` to view existing orders.
2. Create a new order, which will start in the created state.
3. Use the buttons to transition the order through states (`processing`, `completed`, `failed`, `canceled`).

This setup provides a realistic scenario for using OrchestrateFlow in a Rails app with workflows, including order creation and dynamic state transitions.