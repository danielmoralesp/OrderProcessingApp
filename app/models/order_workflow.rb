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