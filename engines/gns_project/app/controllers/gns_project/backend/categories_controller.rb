module GnsProject::Backend
  class CategoriesController < GnsCore::Backend::BackendController
    before_action :set_category, only: [:show, :edit, :update, :destroy]

    # GET /categories
    def index
    end
    
    # POST /categories/list
    def list
      @categories = GnsProject::Category.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
      
      render layout: nil
    end

    # GET /categories/1
    def show
    end

    # GET /categories/new
    def new
      @category = GnsProject::Category.new
    end

    # GET /categories/1/edit
    def edit
    end

    # POST /categories
    def create
      @category = GnsProject::Category.new(category_params)

      if @category.save
        respond_to do |format|
          format.html {
            redirect_to gns_project.backend_categories_path, notice: 'Category was successfully created.'
          }
          format.json {
            render json: {
              status: 'success',
              message: 'The category was successfully created.',
            }
          }
        end
      else
        render :new
      end
    end

    # PATCH/PUT /categories/1
    def update
      if @category.update(category_params)
        respond_to do |format|
          format.html {
            redirect_to gns_project.backend_categories_path, notice: 'Category was successfully updated.'
          }
          format.json {
            render json: {
              status: 'success',
              message: 'The category was successfully deleted.',
            }
          }
        end
      else
        render :edit
      end
    end

    # DELETE /categories/1
    def destroy
      @category.destroy
      
      respond_to do |format|
        format.html {
          redirect_to gns_project.backend_categories_path, notice: 'Category was successfully destroyed.'
        }
        format.json {
          render json: {
            status: 'success',
            message: 'The category was successfully deleted.',
          }
        }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_category
        @category = GnsProject::Category.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def category_params
        params.fetch(:category, {}).permit(:name)
      end
  end
end
