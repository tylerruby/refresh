# Preview all emails at http://localhost:3000/rails/mailers/refund_mailer
class RefundMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/refund_mailer/refund
  def refund
    RefundMailer.refund
  end

end
