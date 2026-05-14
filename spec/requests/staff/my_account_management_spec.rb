require "rails_helper"

RSpec.describe "職員による自分のアカウントの管理", "ログイン前", type: :request do
  include_examples "a protected singular staff controller", "staff/accounts"
end

RSpec.describe "職員による自分のアカウントの管理", type: :request do 
  # 対策1: ログイン処理で使えるように staff_member を最上層に移動
  let(:staff_member) { create(:staff_member, password: "pw") }
  let(:staff_host) { Rails.application.config.baukis2[:staff][:host] } # ※マルチホスト用

  before do
    # 対策3: host を明示的に指定
    post staff_session_url(host: staff_host),
      params: {
        staff_login_form: {
          email: staff_member.email,
          password: "pw"
        }
      }
  end

  describe "情報表示" do
    #let(:staff_member) { create(:staff_member) }

    example "成功" do
      get staff_account_url(host: staff_host)
      expect(response.status).to eq(200)
    end

    example "停止フラグがセットされたら強制的にログアウト" do
      staff_member.update_column(:suspended, true)
      get staff_account_url(host: staff_host)
      expect(response).to redirect_to(staff_root_url(host: staff_host))
    end

    example "セッションタイムアウト" do
      travel_to Staff::Base::TIMEOUT.from_now.advance(seconds: 1)
      get staff_account_url(host: staff_host)
      expect(response).to redirect_to(staff_login_url(host: staff_host))
    end
  end

  describe "更新" do
    #let(:staff_member) { create(:staff_member) }
    let(:params_hash) { attributes_for(:staff_member) }

    example "email属性を変更する" do
      params_hash.merge!(email: "test@example.com")
      patch staff_account_url(host: staff_host),
        params: { id: staff_member.id, staff_member: params_hash }
      staff_member.reload
      expect(staff_member.email).to eq("test@example.com")
    end

    example "staff_memberパラメーターがないと400 Bad Requestを返す" do
      # 対策2: raise_error ではなく 400 エラーのステータスコードを検証する
      patch staff_account_url(host: staff_host), params: { id: staff_member.id }
      expect(response.status).to eq(400)
    end

    #example "例外ActionController::ParameterMissingが発生" do
      #expect { patch staff_account_url(host: staff_host), params: { id: staff_member.id } }.
        #to raise_error(ActionController::ParameterMissing)
    #end

    example "end_dateの値は書き換え不可" do
      # 元のend_dateの値を保持
      original_end_date = staff_member.end_date

      params_hash.merge!(end_date: Date.tomorrow) 
      patch staff_account_url(host: staff_host),
        params: { id: staff_member.id, staff_member: params_hash }
      #expect {
        #patch staff_account_url,
          #params: { id: staff_member.id, staff_member: params_hash }
      #}.not_to change { staff_member.end_date } 

      staff_member.reload
      # ストロングパラメータに含まれていない項目(end_date)が変更されていないことを確認
      expect(staff_member.end_date).to eq(original_end_date)
    end
  end
end