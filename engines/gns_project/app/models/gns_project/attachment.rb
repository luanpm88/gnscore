module GnsProject
  class Attachment < ApplicationRecord
    belongs_to :task, class_name: 'GnsProject::Task'
    
    validates :name, :presence => true
    
    # get task name
    def task_name
      task.present? ? task.name : ''
    end
    
    def self.upload_dir
      return Rails.root.join('storage', 'uploads', 'gns_project', 'attachments')
    end
    
    def upload(file_io)
      readfile = file_io.read
      # check the directory
      dir = Attachment.upload_dir
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      
      # some information
      self.original_name = file_io.original_filename
      self.extension = File.extname(file_io.original_filename)
      self.size = file_io.size
      self.uploaded_at = Time.now
      self.file = Digest::MD5.hexdigest(readfile)
      
      # file path
      path = dir.join(self.file)
      
      File.open(path, "wb") do |file|
        file.write(readfile)
      end
      
      self.save
    end
    
    def file_path
      "#{Attachment.upload_dir}/#{self.file}"
    end
    
    # add log
    def log(phrase, user, remark=nil)
      GnsProject::Log.add_new(self.task.project, phrase, self, user, remark)
    end
  end
end
