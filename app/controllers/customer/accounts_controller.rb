class Customer::AccountsController < Customer::Base 
  def show 
    @customer = current_customer 
  end 
  
  def edit 
    @customer_form = Customer::AccountForm.new(current_customer) 
  end  

  #PATCH 
  def confirm 
    @customer_form = Customer::AccountForm.new(current_customer) 
    @customer_form.assign_attributes(params[:form]) 
    if @customer_form.valid? 
      render action: "confirm" 
    else 
      flash.now.alert = "入力に誤りがあります。"
      render action: "edit", status: :unprocessable_content 
    end     
  end   
  
  def update  
    @customer_form = Customer::AccountForm.new(current_customer)
    @customer_form.assign_attributes(params[:form]) 
    #if params[:commit] || !params[:commit] 
    if params[:correct]  
      # 入力値を保持したまま、Turboにレンダリングを認識させるため status を付与して再表示
      render action: "edit", status: :unprocessable_content  
    else   
      if @customer_form.save 
        flash.notice = "アカウント情報を更新しました。"
        redirect_to :customer_account
      else 
        flash.now.alert = "入力に誤りがあります。"
        render action: "edit", status: :unprocessable_content        
      end  
    end    
  end 
end
