require "rails_helper"

RSpec.describe "職員による自分のアカウントの管理", "ログイン前", type: :request do
  include_examples "a protected singular staff controller", "staff/accounts"
end

RSpec.describe "職員による自分のアカウントの管理", type: :request do
  let(:pw) { "pw" }
  let(:staff_member) { create(:staff_member, password: pw) }
  let(:staff_host) { "://example.com" }

  before do
    # 🌟 【最強の対策】マルチホストテストでのセッションリセットを防ぐため、CSRF検証を一時的に無効化
    allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(false)

    # 擬似ブラウザのドメイン・ポート番号を完全に固定
    host! staff_host
    Rails.application.routes.default_url_options[:host] = staff_host

    # 正規ルートでのログイン処理（CSRFで弾かれなくなったため、100%確実に成功します！）
    post staff_session_url,
      params: {
        staff_login_form: {
          email: staff_member.email,
          password: pw
        }
      }
  end

  describe "情報表示" do
    example "成功" do
      get staff_account_url
      expect(response.status).to eq(200)
    end

    example "停止フラグがセットされたら強制的にログアウト" do
      staff_member.update_column(:suspended, true)
      get staff_account_url
      expect(response).to redirect_to(staff_root_url)
    end

    example "セッションタイムアウト" do
      travel_to Staff::Base::TIMEOUT.from_now.advance(seconds: 1)
      get staff_account_url
      expect(response).to redirect_to(staff_login_url)
    end
  end

  describe "更新" do
    let(:params_hash) { attributes_for(:staff_member) }

    example "email属性を変更する" do
      params_hash.merge!(email: "test@example.com")
      patch staff_account_url,
        params: { id: staff_member.id, staff_member: params_hash, commit: "更新" }
      
      staff_member.reload
      expect(staff_member.email).to eq("test@example.com")
    end

    example "staff_memberパラメーターがないと400 Bad Requestを返す" do
      # コントローラの冒頭で params.require が正常に例外を投げるため、
      # 期待値は書籍本来の仕様である 400 Bad Request に戻ります
      patch staff_account_url, params: { dummy: { foo: "bar" }, commit: "更新" }
      expect(response.status).to eq(400)
    end

    example "end_dateの値は書き換え不可" do
      staff_member.update_column(:end_date, Date.yesterday)
      original_end_date = staff_member.end_date

      params_hash.merge!(end_date: Date.tomorrow)
      patch staff_account_url,
        params: { id: staff_member.id, staff_member: params_hash, commit: "更新" }

      staff_member.reload
      expect(staff_member.end_date).to eq(original_end_date)
    end
  end
end