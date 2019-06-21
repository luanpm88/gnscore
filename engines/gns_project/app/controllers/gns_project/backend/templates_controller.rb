module GnsProject
  module Backend
    class TemplatesController < GnsCore::Backend::BackendController
      before_action :set_template, only: [:show, :edit, :update, :destroy,
                                          :template_details]
  
      # GET /templates
      def index
      end
      
      # POST /templates/list
      def list
        @templates = Template.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
        
        render layout: nil
      end
  
      # GET /templates/1
      def show
      end
  
      # GET /templates/new
      def new
        @template = Template.new
      end
  
      # GET /templates/1/edit
      def edit
      end
  
      # POST /templates
      def create
        @template = Template.new(template_params)
        
        @template.creator = current_user
  
        if @template.save
          # Add notification
          current_user.add_notification("gns_project.notification.template.created", @template)
          
          flash[:success] = 'Template was successfully created.'
          render json: {
            redirect: gns_project.backend_template_path(@template)
          }
        else
          render :new
        end
      end
  
      # PATCH/PUT /templates/1
      def update
        if @template.update(template_params)
          # Add notification
          current_user.add_notification("gns_project.notification.template.updated", @template)
          
          render json: {
            status: 'success',
            message: 'Template was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # DELETE /templates/1
      def destroy
        # Add notification
        current_user.add_notification("gns_project.notification.template.destroyed", @template)
        
        if @template.destroy
          respond_to do |format|
            format.html {
              flash[:success] = 'Template was successfully destroyed.'
              redirect_to gns_project.backend_templates_path
            }
            format.json {
              render json: {
                status: 'success',
                message: 'Template was successfully deleted.',
              }
            }
          end
        else
          respond_to do |format|
            format.html {
              flash[:warning] = @template.errors.full_messages.to_sentence
              redirect_to gns_project.backend_templates_path
            }
            format.json {
              render json: {
                status: 'warning',
                message: @template.errors.full_messages.to_sentence
              }
            }
          end
        end
      end
      
      # SELECT2 /templates
      def select2
        render json: Template.select2(params)
      end
      
      def template_details
        @template_details = @template.template_details.order(:custom_order)
        
        render layout: nil
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_template
          @template = Template.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def template_params
          params.fetch(:template, {}).permit(:name, :category_id, :description)
        end
    end
  end
end
