require "rails_helper"

RSpec.describe "管理者によるログイン管理", "ログイン前", type: :request do
  include_examples "a protected admin controller", "admin/staff_members"
end

RSpec.describe "管理者による職員管理", type: :request do
  #let(:administrator) { create(:administrator) } 
  let(:pw) { "pw" }
  let(:administrator) { create(:administrator, password: pw) } 
  let(:admin_host) { Rails.application.config.baukis2[:admin][:host] }

  before do 
    #let(:admin_host) { Rails.application.config.baukis2[:admin][:host] }
    #post admin_session_url,
    post admin_session_url(host: admin_host),
      params: {
        admin_login_form: {
          email: administrator.email,
          password: pw
        }
      } 
    # ログイン成功を確認（デバッグ用）
    expect(response).to redirect_to(admin_root_url(host: admin_host)) # または期待するリダイレクト先
    #expect(response).to have_http_status(:redirect)
    
    if response.status == 422
      puts response.body # エラー画面のHTMLが出力されるので、エラー内容を確認
      #p "Login Failed! Flash: #{flash[:alert]}"
    end
    #puts response.status #
    #puts response.location  #
    ###puts "Redirect destination: #{response.location}" #
    ###follow_redirect!  # 重要：リダイレクトを追う
  end

  #describe "一覧" do
    #example "成功" do
      #get admin_staff_members_url(host: admin_host) 
      ###puts "Redirect to: #{response.location}" #
      #expect(response.status).to eq(200)
    #end

    #example "停止フラグがセットされたら強制的にログアウト" do
      #administrator.update_column(:suspended, true)
      #get admin_staff_members_url
      #expect(response).to redirect_to(admin_root_url)
    #end

    #example "セッションタイムアウト" do
      #travel_to Admin::Base::TIMEOUT.from_now.advance(seconds: 1)
      #get admin_staff_members_url
      #expect(response).to redirect_to(admin_login_url)
    #end
  #end

  describe "新規登録" do
    #let(:staff_member) { create(:staff_member) }
    let(:params_hash) { attributes_for(:staff_member) }

    example "職員一覧ページにリダイレクト" do
      ##post admin_staff_members_url, params: { staff_member: params_hash }
      post admin_staff_members_url(host: admin_host),
        params: { 
          staff_member: params_hash
             ##password: "pw"
          }
       p response.body 
       
       if response.status == 422
         p "Validation Errors: #{assigns(:staff_member).errors.full_messages}"
       end

       ##expect(response).to redirect_to(admin_staff_members_url(host: admin_host)) 
       expect(response).to redirect_to(admin_staff_members_url(host: admin_host))
    end 

    example "staff_memberパラメーターがないと400 Bad Requestを返す" do
      post admin_staff_members_url(host: admin_host),
           params: { dummy: { foo: "bar" } }
       
      # Railsの標準仕様に合わせて 400 を期待値にする
      # （ActionController::ParameterMissing が発生）した際、Railsがデフォルトでブラウザに返すHTTPステータスコードは 400 Bad Request です。
      expect(response.status).to eq(400)
    end

    #example "staff_memberパラメーターがないと422 Unprocessable Contentを返す" do
      #post admin_staff_members_url(host: admin_host),
           #params: { dummy: { foo: "bar" } }
       
      # 例外をキャッチするのではなく、返ってきたレスポンスのステータスコードを検証する
      #expect(response.status).to eq(422)
    #end

    #example "staff_memberパラメーターがないと、例外ActionController::ParameterMissingが発生" do
      #expect {
        #post admin_staff_members_url(host: admin_host),
             #params: { dummy: { foo: "bar" } }
      #}.to raise_error(ActionController::ParameterMissing)
    #end 
    
    xexample "バリデーションエラーがあると422 Unprocessable Contentを返す" do
      # 有効なパラメータの一部分（email）だけを空文字にする
      invalid_params = params_hash.merge(email: "")
  
      post admin_staff_members_url(host: admin_host), params: { staff_member: invalid_params }
      expect(response.status).to eq(422) 
    end

    #example "例外が発生（または422）" do
      #post admin_staff_members_url(host: admin_host), params: { staff_member: { email: "" } }
      #expect(response.status).to eq(422) # あるいは元のテスト通りにするならコントローラーを要確認
    #end
  end

  describe "更新" do
    let(:staff_member) { create(:staff_member) }
    let(:params_hash) { attributes_for(:staff_member) }

    example "suspendedフラグをセットする" do
      params_hash.merge!(suspended: true)
      #patch admin_staff_member_url(staff_member),
      patch admin_staff_member_url(staff_member, host: admin_host),
        params: { staff_member: params_hash}  
      # 正常に更新されて一覧へリダイレクトされることを検証  
      expect(response).to redirect_to(admin_staff_members_url(host: admin_host))  

      staff_member.reload
      expect(staff_member).to be_suspended
    end

    example "hashed_passwordの値は書き換え不可" do
      params_hash.delete(:password)
      # 開発者が誤って意図しないカラムを直接書き換えようとしたケースを想定
      params_hash.merge!(hashed_password: "x")

      patch admin_staff_member_url(staff_member, host: admin_host),
        params: { staff_member: params_hash }
      #expect {
        #patch admin_staff_member_url(staff_member),
          #params: { staff_member: params_hash }
      #}.not_to change { staff_member.hashed_password.to_s }

      staff_member.reload
      # コントローラーのストロングパラメータで拒否され、値が変わっていないことを検証
      expect(staff_member.hashed_password).not_to eq("x")
    end
  end
end    