class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  skip_before_filter :require_login, only: [:new, :create, :activate, :unlock]

  layout "pages", only: [:new, :create, :destroy]

  def new
    @user = User.new
  end

  def lang_toggle
    if Collection::LANGUAGES.include?(params[:lang_toggle])
      current_user.toggle_language(params[:lang_toggle])
      current_user.save
    end

    redirect_to user_collections_path(current_user)
  end

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @user.activate!
      auto_login(@user)
      redirect_to(user_collections_path(@user), notice: "Welcome, #{@user.first_name}! Your account was successfully activated.")
    else
      flash[:alert] = "Activation token not found"
      not_authenticated
    end
  end

  def unlock
    @user = User.load_from_unlock_token(params[:id])
    if @user
      @user.unlock!
      auto_login(@user)
      redirect_to(user_collections_path(@user), notice: "Your account has been unlocked!")
    else
      flash[:alert] = "Unlock token not found"
      not_authenticated
    end
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to login_path, flash: { success: 'Account created! Please follow the activation link in the email we just sent you.'}
    else
      render action: 'new'
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to edit_user_path(@user), flash: { success: 'Your profile was successfully updated.' }}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    redirect_to home_path
  end

  private
    def set_user
      @user = current_user
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end
end
