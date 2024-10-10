class PostsController < ApplicationController
  # 下記がログインをスキップするための設定
  skip_before_action :require_login, only: [:index]

  before_action :set_post, only: %i[ show ]

  # GET /posts or /posts.json
  def index
    @posts = Post.includes(:user).order(created_at: :desc)
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    @post = current_user.posts.find(params[:id])
  end

  # POST /posts or /posts.json
  def create
    @post = current_user.posts.build(post_params)
    if @post.save
	    flash[:notice] = t('flash.created', item: Post.model_name.human)
      redirect_to root_path
    else
      flash.now[:alert] = t('flash.not_created', item: Post.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    @post = current_user.posts.find(params[:id])
	
    if @post.update(post_params)
      flash[:notice] = t('flash.updated', item: Post.model_name.human)
      redirect_to @post
    else
      flash.now[:alert] = t('flash.not_updated', item: Post.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post = current_user.posts.find(params[:id])  # 現在のユーザーの投稿のみ取得
    @post.destroy!  # 削除を実行
    
    # 削除後、ルートパスにリダイレクトし、フラッシュメッセージを表示
    redirect_to root_path, notice: t('flash.deleted', item: Post.model_name.human), status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :thumbnail)
    end
end
