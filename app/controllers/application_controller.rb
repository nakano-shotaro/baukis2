class ApplicationController < ActionController::Base 
  layout :set_layout 

  #protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: -> { Rails.env.test? }

  class Forbidden < ActionController::ActionControllerError; end 
  class IpAddressRejected < ActionController::ActionControllerError; end 
  
  #include ErrorHandlers if Rails.env.production? 

  private def set_layout 
    if params[:controller].match(%r{\A(staff|admin|customer)/}) 
      Regexp.last_match[1]
    else 
      "customer"      
    end     
  end  
end
