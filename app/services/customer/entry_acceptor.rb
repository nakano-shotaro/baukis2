class Customer::EntryAcceptor 
  def initialize(customer) 
    @customer = customer
  end 
  
  def accept(program) 
    raise if Time.current < program.application_start_time 
    return :closed if Time.current >= program.application_end_time
    ActiveRecord::Base.transaction do 
      program.lock!     
      if program.entries.where(customer_id: @customer.id).exists?
        return :accepted   
      elsif max = program.max_number_of_participants  
        program.entries.where(canceled: false).count < max 
        return :full  
      end 
     
      program.entries.create!(customer: @customer)
        :accepted        
      end 
    end    
  end   
end     