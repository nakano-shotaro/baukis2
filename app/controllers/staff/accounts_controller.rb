class Staff::AccountsController < Staff::Base 
  def show 
    @staff_member = current_staff_member 
  end 
  
  def edit 
    @staff_member = current_staff_member 
  end 

  # PATCH 
  def confirm 
    @staff_member = current_staff_member 
    @staff_member.assign_attributes(staff_member_params) 
    if @staff_member.valid? 
      render action: "confirm" 
    else 
      render action: "edit" 
    end     
  end   

  def update 
    @staff_member = current_staff_member
    @staff_member.assign_attributes(staff_member_params) 

    unless params[:commit]
      render :edit
      return
    end

    #if params[:commit] 
      #if @staff_member.save 
        #flash.notice = "アカウント情報を更新しました。"
        #redirect_to :staff_account 
      #else
        #render :edit,  status: :unprocessable_content 
      #end 
    #else 
      #render action: "edit"   
    #end  

     # 2. 保存処理と条件分岐
    if @staff_member.save
      redirect_to :staff_account, notice: "アカウント情報を更新しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end 

  private def staff_member_params 
    params.require(:staff_member).permit(
      :email, :family_name, :given_name,
      :family_name_kana, :given_name_kana 
    )
  end   
end
