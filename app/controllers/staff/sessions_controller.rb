class Staff::SessionsController < Staff::Base 
  # 必須：ログイン画面とログイン処理では制限をスキップする
  skip_before_action :authorize, only: [ :new, :create ]  
  # Request Spec用のCSRF対策も合わせて確認してください
  skip_before_action :verify_authenticity_token, if: -> { Rails.env.test? }
  

  def new 
    if current_staff_member 
      redirect_to :staff_root   
    else 
      @form = Staff::LoginForm.new 
      render :new   
    end         
  end 
  
  def create 
    @form = Staff::LoginForm.new(login_form_params) 
    if @form.email.present? 
      staff_member = 
        StaffMember.find_by("LOWER(email) = ?", @form.email.downcase)   
    end
     
    if Staff::Authenticator.new(staff_member).authenticate(@form.password) 
      if staff_member.suspended? 
        flash.now.alert = "アカウントが停止されています。"
        render :new, status: :unprocessable_content
      else   
        session[:staff_member_id] = staff_member.id 
        session[:last_access_time] = Time.current   
        flash.notice = "ログインしました。"
        redirect_to :staff_root 
      end     
    else 
      flash.now.alert = "メールアドレスまたはパスワードが正しくありません。"
      render :new, status: :unprocessable_content    
    end        
  end   
  
  def destroy 
    session.delete(:staff_member_id) 
    flash.notice = "ログアウトしました。"
    redirect_to :staff_root, status: :see_other  
  end  
  
  private def login_form_params 
    params.require(:staff_login_form).permit(:email, :password)
  end 
end
