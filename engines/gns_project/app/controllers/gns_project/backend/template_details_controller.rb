module GnsProject
  module Backend
    class TemplateDetailsController < GnsCore::Backend::BackendController
      before_action :set_template_detail, only: [:show, :edit, :update, :destroy]
  
      # GET /template_details
      def index
        @template_details = TemplateDetail.all
      end
  
      # GET /template_details/1
      def show
      end
  
      # GET /template_details/new
      def new
        @template_detail = TemplateDetail.new
        @template_detail.template = Template.find(params[:template_id])
      end
  
      # GET /template_details/1/edit
      def edit
      end
  
      # POST /template_details
      def create
        @template_detail = TemplateDetail.new(template_detail_params)
        
        #@template_detail.creator = current_user
        
        current_template_detail_id = params.to_unsafe_hash[:template_detail][:current_template_detail_id]
        if current_template_detail_id.present?
          current_template_detail = TemplateDetail.find(current_template_detail_id)
        end
        
        if @template_detail.save
          # add below stage
          @template_detail.update_custom_order(current_template_detail)
          
          render json: {
            status: 'success',
            message: 'Template detail was successfully created.',
          }
        else
          render :new
        end
      end
  
      # PATCH/PUT /template_details/1
      def update
        if @template_detail.update(template_detail_params)
          render json: {
            status: 'success',
            message: 'Template detail was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # DELETE /template_details/1
      def destroy
        if @template_detail.destroy
          render json: {
            status: 'success',
            message: 'Template detail was successfully destroyed.',
          }
        else
          render json: {
            status: 'warning',
            message: @template_detail.errors.full_messages.to_sentence
          }
        end
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_template_detail
          @template_detail = TemplateDetail.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def template_detail_params
          params.fetch(:template_detail, {}).permit(:task_description, :template_id, :stage_id)
        end
    end
  end
end
