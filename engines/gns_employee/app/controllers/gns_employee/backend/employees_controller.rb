module GnsEmployee
  module Backend
    class EmployeesController < GnsCore::Backend::BackendController
      before_action :set_employee, only: [:show, :edit, :update, :destroy]
  
      # GET /employees
      def index
      end
  
      # GET /employees
      def list
        @employees = Employee.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
        
        render layout: nil
      end
  
      # GET /employees/1
      def show
      end
  
      # GET /employees/new
      def new
        @employee = Employee.new
      end
  
      # GET /employees/1/edit
      def edit
      end
  
      # POST /employees
      def create
        @employee = Employee.new(employee_params)
  
        if @employee.save
          render json: {
            status: 'success',
            message: 'Category was successfully created.',
          }
        else
          render :new
        end
      end
  
      # PATCH/PUT /employees/1
      def update
        if @employee.update(employee_params)
          render json: {
            status: 'success',
            message: 'Employee was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # DELETE /employees/1
      def destroy
        @employee.destroy
        
        render json: {
          status: 'success',
          message: 'The employee was successfully destroyed.',
        }
      end
      
      # SELECT2 /categories
      def select2
        render json: GnsEmployee::Employee.select2(params)
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_employee
          @employee = Employee.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def employee_params
          params.fetch(:employee, {}).permit(:code, :name, :department, :position, :starting_date,
                                             :phone, :mobile, :email, :labor_contract_type,
                                             :address, :country_id, :state_id, :district_id,
                                             :active)
        end
    end
  end
end
