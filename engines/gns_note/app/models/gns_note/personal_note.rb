module GnsNote
  class PersonalNote < ApplicationRecord
    belongs_to :user, class_name: 'GnsCore::User'
    validates :description, presence: true
    
    def user_name
      user.present? ? user.name : ''
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
  end
end
