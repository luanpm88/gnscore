module GnsNote
  class PersonalNoteMailer < GnsCore::ApplicationMailer
    # send remind note emails
    def send_remind_note_email(options)
      @user = options[:user]
      @note = options[:note]
      send_email("#{@user.email}", "Remind you! There is a personal note to be made before #{@note.due_date.strftime('%d/%m/%Y, %H:%M')}")
    end
  end
end
