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
