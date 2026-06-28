class Customer::TopController < Customer::Base
  skip_before_action :authorize 
  
  def index 
    if current_customer
      render :dashboard
    else   
      render :index 
    end  
  end   
end
