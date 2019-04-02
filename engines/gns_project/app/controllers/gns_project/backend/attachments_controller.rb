module GnsProject
  module Backend
    class AttachmentsController < GnsCore::Backend::BackendController
      before_action :set_attachment, only: [:edit, :update, :destroy]
      
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
        
        uploaded_io = params[:attachment][:file]
        readfile = uploaded_io.read
        
        if @attachment.save
          # md5 attachmentID
          attachment_id = Digest::MD5.hexdigest(@attachment.id.to_s)
          
          # check the directory
          dir = Rails.root.join('storage', 'uploads', 'gns_project', 'attachements', attachment_id)
          Dir.mkdir(dir) unless Dir.exist?(dir)
          
          # file path
          path = dir.join(Digest::MD5.hexdigest(readfile) + '_' + uploaded_io.original_filename)
          
          if @attachment.update_attributes(file: path)
            # write file
            File.open(path, "wb") do |file|
              file.write(readfile)
            end
            
            render json: {
              status: 'success',
              message: 'Attachment was successfully uploaded.',
            }
          end
        else
          render :new
        end
      end
      
      # PATCH/PUT /attachments/1
      def update
        uploaded_io = params[:attachment][:file]
        readfile = uploaded_io.read
        
        # md5 attachmentID
        attachment_id = Digest::MD5.hexdigest(@attachment.id.to_s)
        
        # check the directory
        dir = Rails.root.join('storage', 'uploads', 'gns_project', 'attachements', attachment_id)
        Dir.mkdir(dir) unless Dir.exist?(dir)
        
        # file path
        path = dir.join(Digest::MD5.hexdigest(readfile) + '_' + uploaded_io.original_filename)
        
        @attachment.file = path
        # Check nếu đường dẫn file đã tồn tại thì không cho lưu nữa
        if @attachment.update(attachment_params)
            # write file
            File.open(path, "wb") do |file|
              file.write(readfile)
            end
            
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
