module GnsProject
  module Backend
    class CommentsController < GnsCore::Backend::BackendController
      before_action :set_comment, only: [:edit, :update]
  
      # GET /comments/new
      def new
        @comment = Comment.new
        @comment.project_id = params[:project_id]
          @comment.parent_id = params[:parent_id].present? ? params[:parent_id] : nil
      end
  
      # GET /comments/1/edit
      def edit
      end
  
      # POST /comments
      def create
        @comment = Comment.new(comment_params)
        
        @comment.user = current_user
  
        if @comment.save
          #@comment.log("gns_project.log.comment.created", current_user, @comment.message)
          render json: {
            status: 'success',
            message: 'Comment was successfully created.',
          }
        else
          render :new
        end
      end
  
      # PATCH/PUT /comments/1
      def update
        if @comment.update(comment_params)
          #@comment.log("gns_project.log.comment.updated", current_user, @comment.message)
          
          render json: {
            status: 'success',
            message: 'Comment was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_comment
          @comment = Comment.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def comment_params
          params.fetch(:comment, {}).permit(:message, :file, :project_id, :parent_id)
        end
    end
  end
end
