require 'rails_helper'

RSpec.describe OrderWorkflow do
  let(:workflow) { OrderWorkflow.new }

  describe "initial state" do
    it "sets the initial state to created" do
      expect(workflow.state).to eq(:created)
    end
  end

  describe "state transitions" do
    it "transitions from created to processing on process event" do
      expect { workflow.trigger(:process) }.to change { workflow.state }.from(:created).to(:processing)
    end

    it "transitions from processing to completed on complete event" do
      workflow.trigger(:process)
      expect { workflow.trigger(:complete) }.to change { workflow.state }.from(:processing).to(:completed)
    end

    it "transitions from processing to failed on fail event" do
      workflow.trigger(:process)
      expect { workflow.trigger(:fail) }.to change { workflow.state }.from(:processing).to(:failed)
    end

    it "transitions from created to canceled on cancel event" do
      expect { workflow.trigger(:cancel) }.to change { workflow.state }.from(:created).to(:canceled)
    end
  end

  describe "event actions" do
    it "executes the action associated with the :process event" do
      expect { workflow.trigger(:process) }.to output("Order is being processed.\n").to_stdout
    end

    it "executes the action associated with the :complete event" do
      workflow.trigger(:process)
      expect { workflow.trigger(:complete) }.to output("Order completed sucessfully!\n").to_stdout
    end

    it "executes the action associated with the :fail event" do
      workflow.trigger(:process)
      expect { workflow.trigger(:fail) }.to output("Order processing failed. Notifying support.\n").to_stdout
    end

    it "executes the action associated with the :cancel event" do
      expect { workflow.trigger(:cancel) }.to output("Order has been canceled.\n").to_stdout
    end
  end

  describe "invalid transitions" do
    it "raises an error when an invalid transition is triggered" do
      expect { workflow.trigger(:complete) }.to raise_error(
        OrchestrateFlow::Workflow::InvalidTransitionError,
        "Cannot transition from created using event complete"
      )
    end
  end
end
