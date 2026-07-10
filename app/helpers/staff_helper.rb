module StaffHelper 
  include HtmlBuilder 
  
  def number_of_unprocessed_messages 
    markup do |m| 
      m.a(href: "#", "data-controller" => "messages") do 
        m << "新規問い合わせ" 
        anchor_text = 
          if (c = CustomerMessage.unprocessed.count) > 0 
            "(#{c})" 
          else 
            ""  
          end 
        m.span(
          anchor_text,
          id: "number-of-unprocessed-messages", 
          "data-messages-target" => "badge",
          "data-path" => staff_messages_count_path  
        )    
      end   
    end     
  end   
end     