require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "initial state" do
    it "sets the initial state to created" do
      order = Order.new
      expect(order.status).to eq("created")
    end
  end

  describe "workflow transitions" do
    let(:order) { Order.create(user_id: 1) }

    it "transitions from created to processing on process event" do
      expect { order.update_status(:process) }.to change { order.status }.from("created").to("processing")
    end

    it "transitions from processing to completed on complete event" do
      order.update_status(:process)
      expect { order.update_status(:complete) }.to change { order.status }.from("processing").to("completed")
    end

    it "transitions from processing to failed on fail event" do
      order.update_status(:process)
      expect { order.update_status(:fail) }.to change { order.status }.from("processing").to("failed")
    end

    it "transitions from created to canceled on cancel event" do
      expect { order.update_status(:cancel) }.to change { order.status }.from("created").to("canceled")
    end
  end

  describe "invalid transitions" do
    it "raises an error when attempting an invalid transition" do
      order = Order.create(user_id: 1)
      expect { order.update_status(:complete) }.to raise_error(
        OrchestrateFlow::Workflow::InvalidTransitionError,
        "Cannot transition from created using event complete"
      )
    end
  end
end