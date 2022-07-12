# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    raise ActiveRecord::RecordNotFound if !user_signed_in? && @blog.secret?
    raise ActiveRecord::RecordNotFound if user_signed_in? && @blog.secret? && @blog.user != current_user
  end

  def new
    @blog = Blog.new
  end

  def edit
    raise ActiveRecord::RecordNotFound unless @blog.user == current_user
  end

  def create
    @blog = current_user.blogs.new(blog_params)

    raise ActiveRecord::RecordNotFound if !current_user.premium? && @blog.random_eyecatch

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    raise ActiveRecord::RecordNotFound unless @blog.user == current_user

    if @blog.update(blog_params)
      @blog.update(random_eyecatch: false) if !current_user.premium? && @blog.random_eyecatch
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    raise ActiveRecord::RecordNotFound unless @blog.user == current_user

    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end
end
