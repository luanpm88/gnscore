module GnsProject
  module Backend
    class AttachmentsController < GnsCore::Backend::BackendController
      before_action :set_attachment, only: [:download, :edit, :update, :destroy,
                                            :logs]
      
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
        
        name = params[:attachment][:name]
        fileinput = params[:attachment][:file]
        remark = params[:attachment][:remark]
        
        if !name.present?
          @attachment.errors.add('name', "not be blank")
        end
        
        if !fileinput.present?
          @attachment.errors.add('file', "not be blank")
        end
        
        if !remark.present?
          @attachment.errors.add('remark', "not be blank")
        end
        
        if @attachment.errors.empty?
          if @attachment.save
            @attachment.upload(fileinput)
            @attachment.log("gns_project.log.attachment.uploaded", current_user)
            
            render json: {
              status: 'success',
              message: 'Attachment was successfully uploaded.',
            }
          else
            render :new
          end
        else
          render :new
        end
      end
      
      # PATCH/PUT /attachments/1
      def update
        if !params[:attachment][:remark].present?
          @attachment.errors.add('remark', "not be blank")
        end
        
        if @attachment.errors.empty?
          if @attachment.update(attachment_params)
            # upload file
            @attachment.upload(params[:attachment][:file])
            @attachment.log("gns_project.log.attachment.uploaded", current_user)
            
            render json: {
              status: 'success',
              message: 'Attachment was successfully uploaded.',
            }
          else
            render :edit
          end
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
      
      def logs
      end
      
      def logs_list
        #@logs = GnsProject::Log.all
        render layout: nil
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
