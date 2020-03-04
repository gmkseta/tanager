class ApplicationController < ActionController::Base
  layout "forum"

  helper_method :current_user

  def page_number
    page = params.fetch(:page, '').gsub(/[^0-9]/, '').to_i
    page = "1" if page.zero?
    page
  end

  def is_moderator_or_owner?(object)
    is_moderator? || object.user == current_user
  end
  helper_method :is_moderator_or_owner?

  def is_moderator?
    current_user.respond_to?(:moderator) && current_user.moderator?
  end
  helper_method :is_moderator?

  def require_mod_or_author_for_comment!
    unless is_moderator_or_owner?(@comment)
      redirect_to_root
    end
  end

  def require_mod_or_author_for_post!
    unless is_moderator_or_owner?(@post)
      redirect_to_root
    end
  end

  def authenticate_user!
    redirect_to signup_path if current_user.nil?
  rescue ActiveRecord::RecordNotFound
    redirect_to signup_path
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  private

  def redirect_to_root
    redirect_to "/forum", alert: "실행할 권한이 없습니다"
  end

  def query(definition, variables = {}, context = {})
    response = Cashnote::Client.query(definition, variables: variables, context: context)
    if response.errors.any?
      raise QueryError.new(response.errors[:data].join(", "))
    else
      response.data
    end
  end
end
