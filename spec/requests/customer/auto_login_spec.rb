require "rails_helper" 

describe "次回から自動でログインする" do 
  #let(:customer) { create(:customer) } 
  let(:password) { "pw" } 
  let(:customer) { create(:customer, password: password) } 

  # --- 追加：テスト実行前にCSRF保護をオフにする ---
  before do
    allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(false)
  end
  # -----------------------------------------------
  
  example "チェックボックスをoffにした場合" do 

    # --- デバッグコードを以下に差し替え ---
    allow_any_instance_of(Customer::SessionsController).to receive(:create).and_wrap_original do |m, *args|
      controller_instance = m.receiver
      
      # 1. 実行前のパラメータ確認
      puts "=== [DEBUG] 実行前のコントローラー状態 ==="
      puts "Params: #{controller_instance.params.to_unsafe_h}"
      
      # 2. 処理を実際に実行
      result = m.call(*args)
      
      # 3. 実行後にコントローラー内に生成されたインスタンス変数（@login_form や @form など）をすべて引っ張り出す
      puts "=== [DEBUG] 実行後のインスタンス変数 ==="
      controller_instance.instance_variables.each do |var|
        next if var.to_s.start_with?("@_") # 内部変数はスキップ
        val = controller_instance.instance_variable_get(var)
        puts "#{var}: #{val.inspect}"
        
        # もし errors を持っているオブジェクトがあればその中身も出す
        if val.respond_to?(:errors)
          puts "  -> #{var}.errors: #{val.errors.full_messages}"
        end
      end
      
      puts "======================================="
      result
    end
    # -------------------------------------

    post customer_session_url, 
      params: {
        customer_login_form: {
          email: customer.email, 
          password: password, 
          remember_me: "0"  
        }
      }

    # --- デバッグコードを以下に差し替え ---
    puts "=== 422エラーの解析 ==="
    # 1. 画面上に表示されているエラーメッセージを探す（「メールアドレスが間違っています」など）
    if response.body.include?("alert") || response.body.include?("error")
      puts "HTMLのエラー部分: #{response.body.scan(/<div class=.*?alert.*?>.*?<\/div>/i).join("\n")}"
    end
    
    # 2. コントローラー側でエラーがインスタンス変数に入っているか確認（@form や @login_form など）
    # ※お使いの変数名に合わせて適宜変更してください
    puts "Form Errors: #{controller.instance_variable_get(:@form)&.errors&.full_messages}"
    puts "======================="
    # -------------------------------------

    expect(session[:customer_id]).to eq customer.id  
    expect(cookies[:customer_id]).to be_nil  
  end 
  
  example "チェックボックスをonにした場合" do 
    post customer_session_url, 
      params: {
        customer_login_form: {
          email: customer.email, 
          password: password,
          remember_me: "1"  
        }
      }

    # --- 修正：生データのクッキーから文字列パターンを検証する ---
    expect(cookies["customer_id"]).to match(/[0-9a-f]{40}\z/) 

    cookies = response.request.env["action_dispatch.cookies"]
      .instance_variable_get(:@set_cookies) 
    
    expect(cookies["customer_id"][:expires]).to be > 19.years.from_now  
  end 
end     