class Customer::EntryAcceptor 
  def initialize(customer) 
    @customer = customer
  end 
  
  def accept(program) 
    if (max = program.max_number_of_participants) &&  
      program.entries.where(canceled: false).count < max 
      return :full  
    end 
     
    program.entries.create!(customer: @customer)
      :accepted        
    end     
  end   
end     