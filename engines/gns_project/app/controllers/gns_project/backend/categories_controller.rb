module GnsProject::Backend
  class CategoriesController < GnsCore::Backend::BackendController
    before_action :set_category, only: [:stages, :show, :edit, :update, :destroy,
                                        :activate, :deactivate]

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
      authorize! :read, @category
    end

    # GET /categories/new
    def new
      authorize! :create, GnsProject::Category
      
      @category = GnsProject::Category.new
    end

    # POST /categories
    def create
      authorize! :create, GnsProject::Category
      
      @category = GnsProject::Category.new(category_params)
      
      @category.creator = current_user

      if @category.save
        # Add notification
        @notification = current_user.add_notification("gns_project.notification.category.created", @category)
        @notification.push_to_users(:create_notification, @category)
        
        flash[:success] = 'Category was successfully created.'
        render json: {
          redirect: gns_project.backend_category_path(@category)
        }
      else
        render :new
      end
    end

    # GET /categories/1/edit
    def edit
      authorize! :update, @category
    end

    # PATCH/PUT /categories/1
    def update
      authorize! :update, @category
      
      if @category.update(category_params)
        # Add notification
        @notification = current_user.add_notification("gns_project.notification.category.updated", @category)
        @notification.push_to_users(:update_notification, @category)
        
        render json: {
          status: 'success',
          message: 'Category was successfully updated.',
        }
      else
        render :edit
      end
    end

    # DELETE /categories/1
    def destroy
      authorize! :delete, @category
      
      # Add notification
      @notification = current_user.add_notification("gns_project.notification.category.destroyed", @category)
      @notification.push_to_users(:delete_notification, @category)
      
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
    
    # ACTIVATE /roles/1
    def activate
      authorize! :activate, @category
      
      @category.activate
      
      # Add notification
      @notification = current_user.add_notification("gns_project.notification.category.activated", @category)
      @notification.push_to_users(:activate_notification, @category)
      
      render json: {
        status: 'success',
        message: 'Project type was successfully activated.',
      }
    end
    
    # DEACTIVATE /roles/1
    def deactivate
      authorize! :deactivate, @category
      
      @category.deactivate
      
      # Add notification
      @notification = current_user.add_notification("gns_project.notification.category.deactivated", @category)
      @notification.push_to_users(:deactivate_notification, @category)
      
      render json: {
        status: 'success',
        message: 'Project type was successfully deactivated.',
      }
    end
    
    def stages
      @stages = @category.stages.order(:custom_order)
      
      render layout: nil
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_category
        @category = GnsProject::Category.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def category_params
        params.fetch(:category, {}).permit(:name, :description)
      end
  end
end
