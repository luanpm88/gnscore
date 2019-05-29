module GnsEmployee
  module Backend
    class EmployeesController < GnsCore::Backend::BackendController
      before_action :set_employee, only: [:show, :edit, :update, :destroy,
                                          :account_box, :activate, :deactivate]
  
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
        authorize! :read, @employee
      end
      
      def account_box
        render layout: nil
      end
  
      # GET /employees/new
      def new
        authorize! :create, GnsEmployee::Employee
        @employee = Employee.new
      end
  
      # GET /employees/1/edit
      def edit
        authorize! :update, @employee
      end
  
      # POST /employees
      def create
        authorize! :create, GnsEmployee::Employee
        
        @employee = Employee.new(employee_params)
        @employee.creator = current_user
  
        if @employee.save
          # Add notification
          current_user.add_notification("gns_employee.notification.employee.created", @employee)
          
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
        authorize! :update, @employee
        
        if @employee.update(employee_params)
          # Add notification
          current_user.add_notification("gns_employee.notification.employee.updated", @employee)
          
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
        authorize! :delete, @employee
        
        # Add notification
        current_user.add_notification("gns_employee.notification.employee.deleted", @employee)
        
        if @employee.destroy
          render json: {
            status: 'success',
            message: 'The employee was successfully destroyed.',
          }
        else
          render json: {
            status: 'warning',
            message: @employee.errors.full_messages.to_sentence
          }
        end
      end
      
      # SELECT2 /categories
      def select2
        render json: GnsEmployee::Employee.select2(params)
      end
      
      # ACTIVATE /roles/1
      def activate
        authorize! :activate, @employee
        
        @employee.activate
        
        # Add notification
        current_user.add_notification("gns_employee.notification.employee.activate", @employee)
        
        render json: {
          status: 'success',
          message: 'Employee was successfully activated.',
        }
      end
      
      # DEACTIVATE /roles/1
      def deactivate
        authorize! :deactivate, @employee
        
        @employee.deactivate
        
        # Add notification
        current_user.add_notification("gns_employee.notification.employee.deactivate", @employee)
        
        render json: {
          status: 'success',
          message: 'Employee was successfully deactivated.',
        }
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_employee
          @employee = Employee.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def employee_params
          params.fetch(:employee, {}).permit(:code, :name, :gender, :birthday,
                                             :department, :position, :starting_date, :leaving_date,
                                             :phone, :mobile, :email, :labor_contract_type,
                                             :address, :country_id, :state_id, :district_id)
        end
    end
  end
end
