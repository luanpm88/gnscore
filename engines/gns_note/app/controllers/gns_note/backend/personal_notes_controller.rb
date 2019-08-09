module GnsNote
  module Backend
    class PersonalNotesController < GnsCore::Backend::BackendController
      before_action :set_personal_note, only: [:show, :edit, :update, :destroy,
                                               :mark_as_done, :mark_as_not_done_yet]
  
      # GET /personal_notes
      def list
        @personal_notes = current_user.personal_notes.search(params).paginate(:page => params[:page], :per_page => params[:per_page])
        
        render layout: nil
      end
  
      # GET /personal_notes/1
      def dashboard_note_list
        @personal_notes = current_user.personal_notes.search(params.merge(is_done: 'false')).order('due_date asc').limit(5)
        render layout: nil
      end
  
      # GET /personal_notes/new
      def new
        @personal_note = PersonalNote.new
      end
  
      # GET /personal_notes/1/edit
      def edit
        authorize! :update, @personal_note
      end
  
      # POST /personal_notes
      def create
        @personal_note = PersonalNote.new(personal_note_params)
        @personal_note.user = current_user
  
        if @personal_note.save
          render json: {
            status: 'success',
            message: 'Note was successfully created.',
          }
        else
          render :new
        end
      end
  
      # PATCH/PUT /personal_notes/1
      def update
        authorize! :update, @personal_note
        
        if @personal_note.update(personal_note_params)
          render json: {
            status: 'success',
            message: 'Note was successfully updated.',
          }
        else
          render :edit
        end
      end
  
      # DELETE /personal_notes/1
      def destroy
        authorize! :delete, @personal_note
        
        if @personal_note.destroy
          render json: {
            status: 'success',
            message: 'Note was successfully destroyed.',
          }
        else
          render json: {
            status: 'error',
            message: @personal_note.errors.full_messages.to_sentence
          }
        end
      end
      
      # IS DONE/true /personal_notes/1
      def mark_as_done
        authorize! :mark_as_done, @personal_note
        
        if @personal_note.mark_as_done
          render json: {
            status: 'success',
            message: 'This note have been marked as done.',
          }
        end
      end
      
      # IS DONE/false /personal_notes/1
      def mark_as_not_done_yet
        authorize! :mark_as_not_done_yet, @personal_note
        
        if @personal_note.mark_as_not_done_yet
          render json: {
            status: 'success',
            message: 'This note have been marked as not yet done.',
          }
        end
      end
  
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_personal_note
          @personal_note = PersonalNote.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def personal_note_params
          params.fetch(:personal_note, {}).permit(:description, :due_date)
        end
    end
  end
end
