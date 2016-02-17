require "rails_helper"

RSpec.describe RefundMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:message) { "Your order could not be delivered." }
  describe "refund" do
    let(:mail) { RefundMailer.refund(user, message) }

    it "renders the headers" do
      expect(mail.subject).to eq("Refund")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include(message)
    end
  end
end
