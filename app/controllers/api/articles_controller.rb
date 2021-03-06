class Api::ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  before_action :is_user_journalist?, only: [:create]

  def index
    articles = Article.all
    render json: articles, each_serializer: ArticlesIndexSerializer
  end

  def show
    article = Article.find(params[:id])
    render json: article, serializer: ArticlesShowSerializer
  rescue ActiveRecord::RecordNotFound => e
    render json: { message: 'Something went wrong, this article was not found' }, status: 404
  end

  def create
    article = current_user.articles.create(article_params)
    if article.persisted?
      render json: { message: 'Your article was successfully created!' }, status: 201
    else
      render json: { message: article.errors.full_messages.to_sentence }, status: 422
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :lead, :body, :category_id)
  end

  def is_user_journalist?
    unless current_user.journalist?
      render json: { message: 'You are not authorized to create an article.' }, status: 401
    end
  end
end
