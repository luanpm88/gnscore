module GnsNote
  class PersonalNoteEmailJob < GnsCore::ApplicationJob
    def perform(options)
      @note = GnsNote::PersonalNote.where(id: options[:note_id]).first
      
      if @note.present? #and @remind_at == prev_remind_at
        @user = @note.user
        GnsNote::PersonalNoteMailer.send_remind_note_email({user: @user, note: @note}).deliver_now
      end
    end
  end
end
