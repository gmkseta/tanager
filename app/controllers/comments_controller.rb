class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [:edit, :update]
  before_action :require_mod_or_author_for_comment!, only: [:edit, :update]
  before_action :require_mod_or_author_for_post!, only: [:solved, :unsolved]

  def create
    @comment = @post.comments.new(comment_params)
    @comment.user_id = current_user.id

    if @comment.save
      redirect_to post_path(@post, anchor: "forum_post_#{@comment.id}")
    else
      render template: "simple_discussion/forum_threads/show"
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to post_path(@post)
    else
      render action: :edit
    end
  end

  private

    def set_post
      @post = Post.friendly.find(params[:post_id])
    end

    def set_comment
      if is_moderator?
        @comment = @post.comments.find(params[:id])
      else
        @comment = current_user.comments.find(params[:id])
      end
    end

    def comment_params
      params.require(:comment).permit(:body)
    end
end
