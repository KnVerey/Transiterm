class SessionsController < ApplicationController

	skip_before_filter :require_login, except: [:destroy]
  layout "pages"

  def new
    @user = User.new
  end

  def create
    if @user = login(params[:email], params[:password], params[:remember])
      redirect_to user_collections_path(@user), flash: {success: 'Login successful'}
    else
      @user = User.find_by email: params[:email]

      if @user && @user.unlock_token
        flash.now[:alert] = "Your account has been locked. Please check your email for more information."
      else
        flash.now[:alert] = "Login failed"
      end

      render action: "new"
    end
  end

  def destroy
    logout
    redirect_to(:login, notice: 'Logged out!')
  end
end