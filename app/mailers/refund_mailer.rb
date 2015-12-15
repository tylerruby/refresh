class RefundMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.refund_mailer.refund.subject
  #
  def refund(user, message)
    @message = message

    mail to: user.email
  end
end
