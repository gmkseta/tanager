class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  def signup
    render "/users/new"
  end

  def login
    render "/users/login"
  end

  def login_for_cashnote
    @is_kakaotalk = false
    request.headers.each { |key, value|
      @is_kakaotalk = true if key == "HTTP_USER_AGENT" && value.include?("KAKAOTALK")
    }
    @business_id = params[:business_id] if params.key?(:business_id)
    return redirect_to "/forum" if session[:user_id].present?
    render layout: false
  end

  def logout
    redirect_to "/sessions/logout"
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        format.html { redirect_to "/forum" }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to "/forum", notice: '정보 수정이 완료 되었습니다.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:login, :name, :email, :password)
    end
end
