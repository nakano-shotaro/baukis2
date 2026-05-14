class Staff::TopController < Staff::Base 
  skip_before_action :authorize 

  def index  
    render :index 
  end     
end
