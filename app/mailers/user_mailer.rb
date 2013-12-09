class UserMailer < ActionMailer::Base
  default from: "transiterm@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    @url  = "http://0.0.0.0:3000/users/#{@user.activation_token}/activate"
    mail(:to => user.email,
         :subject => "Welcome to Transiterm")
  end

  def activation_success_email(user)
    @user = user
    @url  = "http://0.0.0.0:3000/login"
    mail(:to => user.email,
         :subject => "Your Transiterm account is now active")
  end

  def send_unlock_token_email(user)
    @user = user
    @url = "http://0.0.0.0:3000/users/#{@user.unlock_token}/unlock"
    mail(to: user.email, subject: "Action needed: Your Transiterm account has been locked")
  end

end
