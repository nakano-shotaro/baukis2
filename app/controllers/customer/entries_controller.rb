class Customer::EntriesController < Customer::Base 
  def create 
    program = Program.published.find(params[:program_id]) 

    #if (max =  program.max_number_of_participants) && 
      #program.entries.where(canceled: false).count  < max 
      #flash.alert = "プログラムへの申込者数が上限に達しました。" 
    #else 
      #program.entries.create!(customer: current_customer)  
      #flash.notice = "プログラムに申し込みました。" 
    #end 
    
    case Customer::EntryAcceptor.new(current_customer).accept(program) 
    when :accepted 
      flash.notice = "プログラムに申し込みました。" 
    when :full 
      flash.alert = "プログラムへの申込者数が上限に達しました。" 
    end            
    redirect_to [ :customer, program ]  
  end     
end
