class Customer::EntryAcceptor 
  def initialize(customer) 
    @customer = customer
  end 
  
  def accept(program) 
    ActiveRecord::Base.transaction do 
      program.lock!     
      if (max = program.max_number_of_participants) &&  
        program.entries.where(canceled: false).count < max 
        return :full  
      end 
     
      program.entries.create!(customer: @customer)
        :accepted        
      end 
    end    
  end   
end     