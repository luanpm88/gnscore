module GnsContact::Backend
  class ContactsController < GnsCore::Backend::BackendController
    before_action :set_contact, only: [:show, :edit, :update, :destroy]

    # GET /contacts
    def index
    end
    
    # POST /contacts/list
    def list
      @contacts = GnsContact::Contact.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
      
      render layout: nil
    end

    # GET /contacts/1
    def show
    end

    # GET /contacts/new
    def new
      @contact = GnsContact::Contact.new
    end

    # GET /contacts/1/edit
    def edit
    end

    # POST /contacts
    def create
      @contact = GnsContact::Contact.new(contact_params)

      if @contact.save
        redirect_to gns_contact.edit_backend_contact_path(@contact), notice: 'Contact was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /contacts/1
    def update
      if @contact.update(contact_params)
        redirect_to gns_contact.backend_contacts_path, notice: 'Contact was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /contacts/1
    def destroy
      @contact.destroy
      
      respond_to do |format|
        format.html {
          redirect_to gns_contact.backend_contacts_path, notice: 'Contact was successfully destroyed.'
        }
        format.json {
          render json: {
            status: 'success',
            message: 'The contact was successfully deleted.',
          }
        }
      end
    end
    
    def select2
      render json: GnsContact::Contact.select2(params)
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_contact
        @contact = GnsContact::Contact.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def contact_params
        params.fetch(:contact, {}).permit(:full_name, :phone, :email, :address)
      end
  end
end
