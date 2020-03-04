class SessionsController < ApplicationController
  def new
    render "/users/login"
  end

  def create
    @user = User.find_by(login: user_params[:login])
    respond_to do |format|
      if @user.authenticate(user_params[:password])
        session[:user_id] = @user.id.to_s
        format.html { redirect_to "/forum" }
      else
        
      end
    end
  end

  def destroy
    reset_session
    redirect_to "/forum"
  end

  private

  def user_params
    params.require(:user).permit(:login, :email, :password)
  end
end
