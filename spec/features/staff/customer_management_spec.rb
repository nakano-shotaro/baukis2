require "rails_helper"

RSpec.feature "職員による顧客管理", type: :feature do   
  include FeaturesSpecHelper 

  let(:staff_member) { create(:staff_member) }
  #let!(:customer) { create(:customer) }
  let!(:customer) { create(:customer) }
  let(:pw) { "pw" } # 未定義だったパスワード変数を定義

  before do 
    switch_namespace(:staff) 
    login_as_staff_member(staff_member)
  end 

  scenario "職員が顧客（基本情報のみ）を追加する" do 
    click_link "顧客管理"
    click_link "新規登録", match: :first 

    fill_in "メールアドレス", with: "member3@example.jp" # test@example.jpではない
    fill_in "パスワード", with: pw
    fill_in "form_customer_family_name", with: "試験"
    fill_in "form_customer_given_name", with: "花子"
    fill_in "form_customer_family_name_kana", with: "シケン"
    fill_in "form_customer_given_name_kana", with: "ハナコ"
    fill_in "生年月日", with: "1970-01-01"
    choose "女性"
    
    # 【重要】
    # 初期コードの「checkしてuncheck」する挙動のせいで不具合が起きていました。
    # 基本情報のみを登録したい（住所は不要）ため、チェックが外れている状態を作ります。
    # もし初期状態でチェックが入っている場合は uncheck だけ行い、
    # 初期状態で外れているなら、以下の2行はコメントアウト（削除）してください
    #check "自宅住所を入力する"
    uncheck "自宅住所を入力する" 
    #check "勤務先を入力する" 
    uncheck "勤務先を入力する" 
    
    click_button "登録"

    # 先に画面が切り替わったことを確認して待機させる
    expect(page).to have_content "顧客を追加しました。"

    new_customer = Customer.order(:id).last 
    expect(new_customer.email).to eq("member3@example.jp") 
    expect(new_customer.birthday).to eq(Date.new(1970, 1, 1))
    expect(new_customer.gender).to eq("female")
    expect(new_customer.home_address).to be_nil 
    expect(new_customer.work_address).to be_nil 
    #expect(page).to have_content "顧客を追加しました。"
  end 
  
  scenario "職員が顧客、自宅住所、勤務先を追加する" do 
    click_link "顧客管理"

    click_link "新規登録", match: :first 

    fill_in "メールアドレス", with: "member3@example.jp"
    fill_in "パスワード", with: "pw"
    fill_in "form_customer_family_name", with: "試験"
    fill_in "form_customer_given_name", with: "花子"
    fill_in "form_customer_family_name_kana", with: "シケン"
    fill_in "form_customer_given_name_kana", with: "ハナコ"
    fill_in "生年月日", with: "1970-01-01"
    choose "女性"

    check "自宅住所を入力する"
    within("fieldset#home-address-fields") do 
      fill_in "郵便番号", with: "1000001"
      select "東京都", from: "都道府県"
      fill_in "市区町村", with: "千代田区"
      fill_in "町域、番地等", with: "千代田 1-1-1"
      fill_in "建物名、部屋番号等", with: ""
    end 
    
    check "勤務先を入力する"
    within("fieldset#work-address-fields") do 
      fill_in "会社名", with: "テスト"
      fill_in "部署名", with: ""
      fill_in "郵便番号", with: ""
      select "", from: "都道府県"
      fill_in "市区町村", with: ""
      fill_in "町域、番地等", with: ""
      fill_in "建物名、部屋番号等", with: ""
    end 

    click_button "登録"

    # 先に画面変化を待つ
    expect(page).to have_content "顧客を追加しました。"

    new_customer = Customer.order(:id).last 
    expect(new_customer.email).to eq("member3@example.jp") 
    expect(new_customer.birthday).to eq(Date.new(1970, 1, 1))
    expect(new_customer.gender).to eq("female")
    expect(new_customer.home_address.postal_code).to eq("1000001") 
    expect(new_customer.work_address.company_name).to eq("テスト") 
    #expect(page).to have_content "顧客を追加しました。"
  end 
  
  scenario "職員が顧客、自宅住所、勤務先を更新する" do 
    click_link "顧客管理"

    within("table.listing") do 
      click_link "編集", match: :first
    end 

    fill_in "メールアドレス", with: "updated@example.jp"

    within("fieldset#home-address-fields") do 
      fill_in "郵便番号", with: "100-0001"
    end 

    within("fieldset#work-address-fields") do 
      fill_in "会社名", with: "更新テスト会社"
    end 

    click_button "更新"

    expect(page).to have_content "顧客情報を更新しました。"

    #customer.reload

    expect(page).to have_content "updated@example.jp"

    # 詳細画面に遷移して画面検証（スレッド分離バグ対策）
    within("table.listing") do
      click_link "詳細", match: :first
    end

    #expect(customer.email).to eq("member3@example.jp") 
    #expect(customer.home_address.postal_code).to eq("1000001") 
    #expect(customer.work_address.company_name).to eq("テスト") 

    #expect(page).to have_content "updated@example.jp"
    expect(page).to have_content "100-0001"
    expect(page).to have_content "更新テスト会社"
  end 
  
  scenario "職員が生年月日と自宅住所の郵便番号に無効な値を入力する" do 
    click_link "顧客管理"

    within("table.listing") do 
      click_link "編集", match: :first
    end 
    
    fill_in "生年月日", with: "2100-01-01" 
    
    within("fieldset#home-address-fields") do 
      fill_in "郵便番号", with: "XYZ" 
    end 

    click_button "更新"

    expect(page).to have_css("header span.alert")  
    expect(page).to have_css(
      "div.field_with_errors input#form_customer_birthday") 
    expect(page).to have_css(
      "div.field_with_errors input#form_home_address_postal_code") 
    #expect(page).to have_css("header span.alert")  
    #expect(page).to have_css("div.field_with_errors input#form_customer_birthday") 
    #expect(page).to have_css("div.field_with_errors input#form_home_address_postal_code")    
  end      

  scenario "職員が勤務先データのない既存顧客に会社名の情報を追加する" do 
    customer.work_address&.destroy 
    customer.reload # 削除を確実に反映

    click_link "顧客管理"

    #first("table.listing").click_link "編集" 
    within("table.listing") do 
      click_link "編集", match: :first
    end 

    check "勤務先を入力する" 
    within("fieldset#work-address-fields") do 
      fill_in "会社名", with: "テスト"
    end
    click_button "更新"
    
    expect(page).to have_content "顧客情報を更新しました。"

    within("table.listing") do
      click_link "詳細", match: :first
    end

    # 画面に値が表示されているか確認を挟む
    expect(page).to have_content "テスト"

    # DBをリロードして検証
    #customer.reload 

    #expect(customer.work_address).not_to be_nil # まずnilでないことを確認
    #expect(customer.work_address.company_name).to eq("テスト")
    #expect(page).to have_content "新規テスト会社"
  end   
end     