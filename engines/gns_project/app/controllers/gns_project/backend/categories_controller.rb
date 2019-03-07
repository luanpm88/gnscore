module GnsProject::Backend
  class CategoriesController < GnsCore::Backend::BackendController
    before_action :set_category, only: [:stages, :show, :edit, :update, :destroy]

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
            flash[:success] = 'Category was successfully created.'
            redirect_to gns_project.backend_category_path(@category)
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
            flash[:success] = 'Category was successfully updated.'
            redirect_to gns_project.backend_category_path(@category)
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
      if @category.destroy
        respond_to do |format|
          format.html {
            flash[:success] = 'Category was successfully destroyed.'
            redirect_to gns_project.backend_categories_path
          }
          format.json {
            render json: {
              status: 'success',
              message: 'The category was successfully deleted.',
            }
          }
        end
      else
        respond_to do |format|
          format.html {
            flash[:warning] = @category.errors.full_messages.to_sentence
            redirect_to gns_project.backend_categories_path
          }
          format.json {
            render json: {
              status: 'warning',
              message: @category.errors.full_messages.to_sentence
            }
          }
        end
      end
    end
    
    # SELECT2 /categories
    def select2
      render json: GnsProject::Category.select2(params)
    end
    
    def stages
      render layout: nil
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
