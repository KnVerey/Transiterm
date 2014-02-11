class UserMailer < ActionMailer::Base
  default from: "transiterm@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    @url  = activate_user_url(@user.activation_token)
    mail(:to => @user.email,
         :subject => "Welcome to Transiterm")
  end

  def activation_success_email(user)
    @user = user
    @url  = login_url
    mail(:to => @user.email,
         :subject => "Your Transiterm account is now active")
  end

  def send_unlock_token_email(user)
    @user = user
    @url = unlock_user_url(@user.unlock_token)
    mail(to: @user.email, subject: "Action needed: Your Transiterm account has been locked")
  end

  def reset_password_email(user)
    @user = user
    @url = edit_password_reset_url(@user.reset_password_token)
    mail(:to => @user.email,
       :subject => "Your password has been reset")
  end

end
