module GnsProject
  module Backend
    class StagesController < GnsCore::Backend::BackendController
      before_action :set_stage, only: [:show, :edit, :update, :destroy]
  
      # GET /stages
      def index
        @stages = Stage.all
      end
  
      # GET /stages/1
      def show
        authorize! :read, @stage
      end
  
      # GET /stages/new
      def new
        authorize! :create, GnsProject::Stage
        
        @stage = Stage.new
        @stage.category = Category.find(params[:category_id])
      end
  
      # POST /stages
      def create
        authorize! :create, GnsProject::Stage
        
        @stage = Stage.new(stage_params)
        
        current_stage_id = params.to_unsafe_hash[:stage][:current_stage_id]
        if current_stage_id.present?
          current_stage = Stage.find(current_stage_id)
        end
        
        if @stage.save
          
          # add below stage
          @stage.update_custom_order(current_stage)
          
          # Add notification
          @notification = current_user.add_notification("gns_project.notification.stage.created", @stage)
          @notification.push_to_users(:create_notification, @stage)
          
          flash[:success] = 'Stage was successfully created.'
          
          render json: {
            status: 'success',
            message: 'Stage was successfully created.',
          }
        else
          render :new
        end
      end
  
      # GET /stages/1/edit
      def edit
        authorize! :update, @stage
      end
  
      # PATCH/PUT /stages/1
      def update
        authorize! :update, @stage
        
        if @stage.update(stage_params)
          # Add notification
          @notification = current_user.add_notification("gns_project.notification.stage.updated", @stage)
          @notification.push_to_users(:update_notification, @stage)
          
          render json: {
            status: 'success',
            message: 'Stage was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # DELETE /stages/1
      def destroy
        authorize! :delete, @stage
        
        # Add notification
        @notification = current_user.add_notification("gns_project.notification.stage.deleted", @stage)
        @notification.push_to_users(:delete_notification, @stage)
        
        @stage.destroy
        
        if !@stage.errors.empty?
          render json: {
            status: 'error',
            message: @stage.errors.full_messages.to_sentence,
          }
        else
          render json: {
            status: 'success',
            message: 'Stage was successfully destroyed.',
          }
        end
      end
      
      # SELECT2 /stages
      def select2
        render json: GnsProject::Stage.select2(params)
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_stage
          @stage = Stage.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def stage_params
          params.fetch(:stage, {}).permit(:category_id, :name, :description)
        end
    end
  end
end
