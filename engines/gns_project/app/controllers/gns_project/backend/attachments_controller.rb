module GnsProject
  module Backend
    class AttachmentsController < GnsCore::Backend::BackendController
      before_action :set_attachment, only: [:download, :edit, :update, :destroy]
      
      def history
        render layout: nil
      end
  
      ## GET /attachments
      #def index
      #  @attachments = Attachment.all
      #end
      
      # GET /attachments/1
      def show
        @attachment = Attachment.new
      end
      
      def logs
        render layout: nil
      end
      
      # GET /attachments/new
      def new
        @attachment = Attachment.new
      end
      
      # GET /attachments/1/edit
      def edit
      end
      
      # POST /attachments
      def create
        @attachment = Attachment.new(attachment_params)
        
        if @attachment.save
          @attachment.upload(params[:attachment][:file])
          
          render json: {
            status: 'success',
            message: 'Attachment was successfully uploaded.',
          }
        else
          render :new
        end
      end
      
      # PATCH/PUT /attachments/1
      def update
        if @attachment.update(attachment_params)
          # upload file
          @attachment.upload(params[:attachment][:file]) 
          
          render json: {
            status: 'success',
            message: 'Attachment was successfully uploaded.',
          }
        else
          render :edit
        end
      end
      
      # DELETE /attachments/1
      #def destroy
      #  @attachment.destroy
      #  redirect_to attachments_url, notice: 'Attachment was successfully destroyed.'
      #end
      
      def download
        send_file(
          @attachment.file_path,
          filename: @attachment.original_name
        )
      end
      
      def log_download
        #@log = Log.find(params[:att_log_id]);
        #"#{@log.getData['upload_dir']}/#{@log.getData['file']}",
        #  filename: @attachment.original_name
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_attachment
          @attachment = Attachment.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def attachment_params
          params.fetch(:attachment, {}).permit(:name, :task_id)
        end
    end
  end
end
