module GnsContact
  module Backend
    class ContactsController < GnsCore::Backend::BackendController
      before_action :set_contact, only: [:edit, :update, :destroy,
                                         :add_subcontact, :subcontact_edit, :subcontact_update,
                                         :remove_subcontact, :subcontact_list, :show, :projects]
  
      # GET /contacts
      def index
      end
      
      # POST /contacts/list
      def list
        @contacts = Contact.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
        
        render layout: nil
      end
  
      # GET /contacts/1
      def show
      end
      
      # GET /contacts/1/projects
      def projects
      end
  
      # GET /contacts/new
      def new
        @contact = Contact.new
      end
      
      # GET /contacts/subcontact_new
      def subcontact_new
        @contact = Contact.new
        @contact.parent_ids = params[:parent_id]
        @contact.category_ids = Contact.find(params[:parent_id]).category_ids
      end
  
      # GET /contacts/1/edit
      def edit
      end
      
      # GET /contacts/subcontact_edit
      def subcontact_edit
      end
  
      # POST /contacts
      def create
        @contact = Contact.new(contact_params)
        
        @contact.contact_type = GnsContact::Contact::TYPE_COMPANY
  
        if @contact.save
          # Add notification
          current_user.add_notification("gns_contact.notification.contact.created", {
            name: @contact.full_name
          })
          
          flash[:success] = 'Contact was successfully created.'
          render json: {
            redirect: gns_contact.backend_contact_path(@contact)
          }
        else
          render :new
        end
      end
      
      # POST /contacts
      def subcontact_create
        @contact = Contact.new(contact_params)
        
        @contact.contact_type = GnsContact::Contact::TYPE_PERSON
  
        if @contact.save
          render json: {
            status: 'success',
            message: 'Sub-contact was successfully created.',
          }
        else
          render :subcontact_new
        end
      end
  
      # PATCH/PUT /contacts/1
      def update
        if @contact.update(contact_params)
          # Add notification
          current_user.add_notification("gns_contact.notification.contact.updated", {
            name: @contact.full_name
          })
          
          render json: {
            status: 'success',
            message: 'Contact was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # PATCH/PUT /contacts/1
      def subcontact_update
        if @contact.update(contact_params)
          # Add notification
          current_user.add_notification("gns_contact.notification.contact.updated", {
            name: @contact.full_name
          })
          
          render json: {
            status: 'success',
            message: 'Sub-contact was successfully updated.',
          }
        else
          render :subcontact_edit
        end
      end
  
      # DELETE /contacts/1
      def destroy
        if @contact.destroy
          respond_to do |format|
            format.html {
              flash[:success] = 'Contact was successfully destroyed.'
              redirect_to gns_contact.backend_contacts_path
            }
            format.json {
              render json: {
                status: 'success',
                message: 'The contact was successfully deleted.',
              }
            }
          end
        else
          respond_to do |format|
            format.html {
              flash[:warning] = @contact.errors.full_messages.to_sentence
              redirect_to gns_contact.backend_contacts_path
            }
            format.json {
              render json: {
                status: 'warning',
                message: @contact.errors.full_messages.to_sentence
              }
            }
          end
        end
      end
      
      def select2
        render json: Contact.select2(params)
      end
      
      def add_subcontact
        @child_contact = @contact.children_contacts.new(contact_id: params[:contact_id])
  
        if request.post?
          if !@child_contact.contact_id.present?
            @child_contact.errors.add('contact_id', "contact must not be empty")
          end
          
          if @child_contact.errors.empty?
            @child_contact.save
            render json: {
              status: 'success',
              message: 'Sub-contact was successfully created.',
            }
          end     
        end
      end
      
      def subcontact_list
        render layout: nil
      end
      
      # @todo: xoa sub-contact khoi contact cha hien tai
      def remove_subcontact
        @contact.parent.delete(params[:current_parent_id])
        render json: {
          status: 'success',
          message: 'The sub-contact was successfully removed.',
        }
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_contact
          @contact = Contact.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def contact_params
          params.fetch(:contact, {}).permit(:code, :full_name, :foreign_name, :phone, :email, :mobile,
                                            :tax_code, :website, :fax, :invoice_address, :description,
                                            :contact_type, :active,
                                            :address, :country_id, :state_id, :district_id,
                                            :birthday, :department, :position,
                                            category_ids: [], parent_ids: [])
        end
    end
  end
end
