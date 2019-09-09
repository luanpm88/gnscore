module GnsNote
  class PersonalNote < ApplicationRecord
    belongs_to :user, class_name: 'GnsCore::User'
    validates :description, presence: true
    
    def user_name
      user.present? ? user.name : ''
    end
    
    # class const
    REMINDER_NONE = 'none'
    REMINDER_00_MINUTES = '0_minutes'
    REMINDER_05_MINUTES = '5_minutes'
    REMINDER_15_MINUTES = '15_minutes'
    REMINDER_30_MINUTES = '30_minutes'
    REMINDER_01_HOUR = '1_hour'
    REMINDER_12_HOURS = '12_hours'
    REMINDER_01_DAY = '1_day'
    REMINDER_01_WEEK = '1_week'
    
    # get reminder
    def self.get_reminder_options()
      [
        {text: I18n.t('gns_note.none'),value: self::REMINDER_NONE},
        {text: I18n.t('gns_note.0_minutes'),value: self::REMINDER_00_MINUTES},
        {text: I18n.t('gns_note.5_minutes'),value: self::REMINDER_05_MINUTES},
        {text: I18n.t('gns_note.15_minutes'),value: self::REMINDER_15_MINUTES},
        {text: I18n.t('gns_note.30_minutes'),value: self::REMINDER_30_MINUTES},
        {text: I18n.t('gns_note.1_hour'),value: self::REMINDER_01_HOUR},
        {text: I18n.t('gns_note.12_hours'),value: self::REMINDER_12_HOURS},
        {text: I18n.t('gns_note.1_day'),value: self::REMINDER_01_DAY},
        {text: I18n.t('gns_note.1_week'),value: self::REMINDER_01_WEEK},
      ]
    end
    
    # filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # filter by active
      if params[:is_done].present?
        query = query.where(is_done: params[:is_done])
      end
      
      if params[:user_id].present?
        query = query.where(user_id: params[:user_id])
      end
      
      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(gns_note_personal_notes.description) LIKE ?', '%'+q.to_ascii.downcase+'%')
				end
			end

      return query
    end
    
    # searchs
    def self.search(params)
      query = self.all
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      end

      return query
    end
    
    # mark as done
    def mark_as_done
			update_attributes(is_done: true)
		end
    
    # mark as not done yet
    def mark_as_not_done_yet
			update_attributes(is_done: false)
		end
    
    # set remind
    def remind_at
      if due_date.present? and reminder.present?
        case
        when reminder == REMINDER_00_MINUTES
          return due_date
        when reminder == REMINDER_05_MINUTES
          return due_date - 5.minutes
        when reminder == REMINDER_15_MINUTES
          return due_date - 15.minutes
        when reminder == REMINDER_30_MINUTES
          return due_date - 30.minutes
        when reminder == REMINDER_01_HOUR
          return due_date - 1.hour
        when reminder == REMINDER_12_HOURS
          return due_date - 12.hours
        when reminder == REMINDER_01_DAY
          return due_date - 1.day
        when reminder == REMINDER_01_WEEK
          return due_date - 1.week
        else
          return nil
        end
      else
        return nil
      end
    end

  end
end
