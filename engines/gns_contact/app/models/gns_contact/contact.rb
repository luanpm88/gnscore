module GnsContact
  class Contact < ApplicationRecord
    validates :full_name, :presence => true
    
    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      if params[:state_id].present?
        query = query.where(state_id: params[:state_id])
      end
      
      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(gns_contact_contacts.full_name) LIKE ?', '%'+q.to_ascii.downcase+'%')
				end
			end

      return query
    end
    
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
    
    def self.select2(params)
      per_page = 10
      page = 1      
      data = {results: [], pagination: {more: false}}
      
      query = self.all
      
      # keyword
      if params[:q].present?
        query = query.where('LOWER(gns_contact_contacts.full_name) LIKE ?', '%'+params[:q].to_ascii.downcase+'%')
      end
      
      # pagination
      page = params[:page].to_i if params[:page].present?
      query = self.limit(per_page).offset(per_page*(page-1))      
      data[:pagination][:more] = true if query.count > 0
      
      # render items
      query.each do |c|
        data[:results] << {id: c.id, text: c.full_name}
      end
      
      return data
    end
  end
end
