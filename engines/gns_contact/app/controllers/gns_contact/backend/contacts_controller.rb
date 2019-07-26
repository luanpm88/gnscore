module GnsContact
  module Backend
    class ContactsController < GnsCore::Backend::BackendController
      before_action :set_contact, only: [:edit, :update, :destroy,
                                         :activate, :deactivate,
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
        authorize! :create, Contact
        
        @contact = Contact.new
      end
      
      # GET /contacts/subcontact_new
      def subcontact_new
        authorize! :create, Contact
        
        @contact = Contact.new
        @contact.parent_ids = params[:parent_id]
        @contact.category_ids = Contact.find(params[:parent_id]).category_ids
      end
  
      # GET /contacts/1/edit
      def edit
        authorize! :update, @contact
      end
      
      # GET /contacts/subcontact_edit
      def subcontact_edit
        authorize! :update, @contact
      end
  
      # POST /contacts
      def create
        authorize! :create, Contact
        
        @contact = Contact.new(contact_params)
        
        @contact.creator = current_user
        @contact.contact_type = GnsContact::Contact::TYPE_COMPANY
  
        if @contact.save
          # Add notification
          @notification = current_user.add_notification("gns_contact.notification.contact.created", @contact)
          @notification.push_to_users(type='gns_contact.contacts.create.notification')
          
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
        authorize! :create, Contact
        
        @contact = Contact.new(contact_params)
        
        @contact.creator = current_user
        @contact.contact_type = GnsContact::Contact::TYPE_PERSON
  
        if @contact.save
          # add notification
          #current_user.add_notification("gns_contact.notification.contact.created", @contact)
          @notification = current_user.add_notification("gns_contact.notification.contact.created", @contact)
          @notification.push_to_users(type='gns_contact.contacts.create.notification')
          
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
        authorize! :update, @contact
        
        if @contact.update(contact_params)
          # Add notification
          #current_user.add_notification("gns_contact.notification.contact.updated", @contact)
          @notification = current_user.add_notification("gns_contact.notification.contact.updated", @contact)
          @notification.push_to_users(type='gns_contact.contacts.update_own.notification')
          
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
        authorize! :update, @contact
        
        if @contact.update(contact_params)
          # Add notification
          @notification = current_user.add_notification("gns_contact.notification.contact.updated", @contact)
          @notification.push_to_users(type='gns_contact.contacts.update_own.notification')
          
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
        authorize! :delete, @contact
        
        # Add notification
        @notification = current_user.add_notification("gns_contact.notification.contact.deleted", @contact)
        @notification.push_to_users(type='gns_contact.contacts.delete_own.notification')
        
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
      
      # ACTIVATE /roles/1
      def activate
        authorize! :activate, @contact
        
        @contact.activate
        
        # Add notification
        @notification = current_user.add_notification("gns_contact.notification.contact.activate", @contact)
        @notification.push_to_users(type='gns_contact.contacts.activate_own.notification')
        
        render json: {
          status: 'success',
          message: 'Contact was successfully activated.',
        }
      end
      
      # DEACTIVATE /roles/1
      def deactivate
        authorize! :deactivate, @contact
        
        @contact.deactivate
        
        # Add notification
        @notification = current_user.add_notification("gns_contact.notification.contact.deactivate", @contact)
        @notification.push_to_users(type='gns_contact.contacts.deactivate_own.notification')
        
        render json: {
          status: 'success',
          message: 'Contact was successfully deactivated.',
        }
      end
      
      def add_subcontact
        authorize! :update, @contact
        
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
        authorize! :update, @contact
        
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
