class Api::PostsController < ApplicationController
  def index
    render json: Post.all
  end

  def create
    post = Post.create!(safe_params)
    render json: post, status: 201
  end
  
  def update
    post.update_attributes(safe_params)
    render nothing: true, status: 204
  end

  def destroy
    post.destroy
    render nothing: true, status: 204
  end

  def safe_params
    params.require(:post).permit(:title, :body, :filepicker_url)
  end

  def post
    Post.find(params[:id])
  end

end