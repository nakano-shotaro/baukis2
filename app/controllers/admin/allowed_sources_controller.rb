class Admin::AllowedSourcesController < Admin::Base 
  def index 
    @allowed_sources = AllowedSource.where(namespace: "staff") 
      .order(:octet1, :octet2, :octet3, :octet4) 
    @new_allowed_source = AllowedSource.new  
  end     
end
