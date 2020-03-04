class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:mine, :participating, :new, :create]
  before_action :set_post, only: [:show, :edit, :update]
  before_action :require_mod_or_author_for_post!, only: [:edit, :update]

  def index
    @posts = Post.sorted.includes(:user, :categories, :comments).paginate(page: page_number)
  end

  def mine
    @posts = Post.where(user: current_user).sorted.includes(:user, :categories).paginate(page: page_number)
    render action: :index
  end

  def participating
    @posts = Post.includes(:user, :categories).joins(:comments).where(comments: { user_id: current_user.id }).distinct(posts: :id).sorted.paginate(page: page_number)
    render action: :index
  end

  def show
    @comment = Comment.new
    @comment.user = current_user
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)
    @post.post_categories.each{ |post_category| post_category.post_id = @post.id }
    @post.comments.each{ |comment| comment.user_id = current_user.id }
    if @post.save
      redirect_to post_path(@post)
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to post_path(@post), notice: I18n.t('업데이트가 완료 되었습니다.')
    else
      render action: :edit
    end
  end

  private

    def set_post
      @post = Post.friendly.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, category_ids: [], comments_attributes: [:id, :body])
    end
end
