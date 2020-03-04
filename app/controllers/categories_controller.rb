class CategoriesController < ApplicationController
  before_action :set_category

  def index
    @posts = Post.joins(:categories).where(post_categories: { category_id: @category.id } ).distinct if @category.present?
    @posts = @posts.sorted.includes(:user, :categories, :post_categories, :comments).paginate(per_page: 10, page: page_number)
    render "/posts/index"
  end

  private

    def set_category
      @category = Category.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to "/posts/index"
    end
end
