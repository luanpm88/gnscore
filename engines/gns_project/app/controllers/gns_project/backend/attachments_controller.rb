module GnsProject
  module Backend
    class AttachmentsController < GnsCore::Backend::BackendController
      before_action :set_attachment, only: [:download, :edit, :update, :destroy,
                                            :logs, :logs_list, :log_download]
      
      # GET /attachments/1
      def show
        @attachment = Attachment.new
      end
      
      # GET /attachments/new
      def new
        @attachment = Attachment.new
        @attachment.task_id = params[:task_id]
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
            @attachment.log("gns_project.log.attachment.created", current_user, remark)
            
            render json: {
              status: 'success',
              message: 'Attachment was successfully created.',
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
        name = params[:attachment][:name]
        fileinput = params[:attachment][:file]
        remark = params[:attachment][:remark]
        if !name.present?
          @attachment.errors.add('name', "not be blank")
        end
        
        if !remark.present?
          @attachment.errors.add('remark', "not be blank")
        end
        
        if @attachment.errors.empty?
          if @attachment.update(attachment_params)
            # upload file
            
            if fileinput.present?
              @attachment.upload(fileinput)
              @attachment.log("gns_project.log.attachment.reupload", current_user, remark)
            else
              @attachment.log("gns_project.log.attachment.updated", current_user, remark)
            end
            
            render json: {
              status: 'success',
              message: 'Attachment was successfully updated.',
            }
          else
            render :edit
          end
        else
          render :edit
        end
      end
      
      # DELETE /attachments/1
      def destroy
        @attachment.log("gns_project.log.attachment.destroyed", current_user)
        
        @attachment.destroy
        
        render json: {
          status: 'success',
          message: 'Attachment was successfully destroyed.',
        }
      end
      
      # SELECT2 /tasks
      def select2
        render json: GnsProject::Attachment.select2(params)
      end
      
      def download
        authorize! :download, @attachment
        
        send_file(
          @attachment.file_path,
          filename: @attachment.original_name
        )
      end
      
      def logs
      end
      
      def logs_list
        @logs = @attachment.logs
        render layout: nil
      end
      
      def log_download
        @attachment_log = GnsProject::Log.find(params[:attachment_log_id])
        
        send_file(
          "#{Attachment.upload_dir}/#{@attachment_log.get_data.file}",
          filename: @attachment_log.get_data.original_name
        )
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
