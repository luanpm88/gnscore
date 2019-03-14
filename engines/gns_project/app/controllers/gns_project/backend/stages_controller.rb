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
      end
  
      # GET /stages/new
      def new
        @stage = Stage.new
        @stage.category = Category.find(params[:category_id])
      end
  
      # GET /stages/1/edit
      def edit
      end
  
      # POST /stages
      def create
        @stage = Stage.new(stage_params)
  
        if @stage.save
          flash[:success] = 'Stage was successfully created.'
          
          render json: {
            status: 'success',
            message: 'Stage was successfully created.',
          }
        else
          render :new
        end
      end
  
      # PATCH/PUT /stages/1
      def update
        if @stage.update(stage_params)
          flash[:success] = 'Stage was successfully updated.'
          
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
        @stage.destroy
          
        render json: {
          status: 'success',
          message: 'Stage was successfully destroyed.',
        }
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
          params.fetch(:stage, {}).permit(:category_id, :name)
        end
    end
  end
end
