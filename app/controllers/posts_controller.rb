class PostsController < ApplicationController
  # 下記がログインをスキップするための設定
  skip_before_action :require_login, only: [ :index ]

  before_action :set_post, only: %i[ show ]

  # GET /posts or /posts.json
  def index
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true).includes(:user).order(created_at: :desc)
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
      flash[:notice] = t("flash.created", item: Post.model_name.human)
      redirect_to root_path
    else
      flash.now[:alert] = t("flash.not_created", item: Post.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    @post = current_user.posts.find(params[:id])

    # 空の`main_images`をパラメータから削除する
    if params[:post][:main_images].present? && params[:post][:main_images].reject(&:blank?).empty?
      params[:post].delete(:main_images)
    end

    # `main_images`が存在する場合のみ画像を添付
    if params[:post][:main_images].present?
      @post.main_images.attach(params[:post][:main_images])
    end

    # 投稿の更新
    if @post.update(post_params)
      flash[:notice] = t("flash.updated", item: Post.model_name.human)
      redirect_to @post
    else
      flash.now[:alert] = t("flash.not_updated", item: Post.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post = current_user.posts.find(params[:id])  # 現在のユーザーの投稿のみ取得
    @post.destroy!  # 削除を実行

    # 削除後、ルートパスにリダイレクトし、フラッシュメッセージを表示
    redirect_to root_path, notice: t("flash.deleted", item: Post.model_name.human), status: :see_other
  end

  def destroy_image
    @post = Post.find(params[:post_id])
    image = @post.main_images.find(params[:id])  # ActiveStorage::Attachment を取得

    if image.present?
      image.purge  # 画像のアタッチメントと実際のファイルを削除
      redirect_to edit_post_path(@post), notice: "画像を削除しました"
    else
      redirect_to edit_post_path(@post), alert: "画像の削除に失敗しました"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :thumbnail, main_images: [])
    end
end
