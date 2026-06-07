require "rails_helper" 

feature "職員による顧客電話番号管理" do 
  include FeaturesSpecHelper 
  let(:staff_member) { create(:staff_member) }
  let!(:customer) { create(:customer) } 
  
  before do 
    switch_namespace(:staff)
    login_as_staff_member(staff_member)
  end 
  
  scenario "職員が顧客の電話番号を追加する" do 
    click_link "顧客管理"

    #first("table.listing").click_link "編集" 
    within("table.listing") do 
      click_link "編集", match: :first
    end 

    fill_in "form_customer_phones_0_number", with: "090-9999-9999"  
    #fill_in "form[customer][phones][0][number]", with: "090-9999-9999"
    #fill_in "電話番号", with: "090-9999-9999"
    check "form_customer_phones_0_primary"
    #check "form[customer][phones][0][primary]" 
    #within(first(".phone-fields")) do # 実際のHTMLのクラス名に合わせてください
      #check "優先"
    #end
    click_button "更新"

    #puts page.text # テスト実行時のターミナルに、その時の画面の全テキストを強制出力します
    #puts page.html 
    #save_and_open_page
    expect(page).to have_content "顧客情報を更新しました。"
    #expect(page).to have_link "新規登録"

    #customer.reload 

    # データベースのreloadを辞め、画面遷移して登録された電話番号が表示されているか検証する
    # ※Baukis2の仕様上、更新後は一覧画面（index）に戻るため、対象の顧客の「詳細」リンクをクリックします
    within("table.listing") do
      click_link "詳細", match: :first
    end

    # 【デバッグ用コードを追加】
    #p "=== Customer Errors ==="
    #p customer.errors.full_messages
    #p "=== Phone Errors ==="
    #p customer.personal_phones.map { |p| [p.number, p.errors.full_messages] }

    #expect(customer.personal_phones.size).to eq(1) 
    #expect(customer.personal_phones[0].number).to eq("090-9999-9999")

     # 詳細画面（show）に、追加した電話番号が表示されていることを確認する
    expect(page).to have_content "090-9999-9999"
  end  
  
  scenario "職員が顧客の自宅電話番号を追加する" do 
    click_link "顧客管理"

    #first("table.listing").click_link "編集"
    within("table.listing") do 
      click_link "編集", match: :first
    end  

    fill_in "form_home_address_phones_0_number", with: "03-9999-9999" 
    check "form_home_address_phones_0_primary" 
    click_button "更新" 

    expect(page).to have_content "顧客情報を更新しました。" 

    #customer.reload 
    
    within("table.listing") do
      click_link "詳細", match: :first
    end

    #except(customer.home_address.phones.size).to eq(1)
    #except(customer.home_address.phones[0].number).to eq("03-9999-9999") 
    expect(page).to have_content "03-9999-9999"
  end 
  
  scenario "職員が顧客の勤務先電話番号を追加する" do 
    click_link "顧客管理"

    #first("table.listing").click_link "編集"
    within("table.listing") do 
      click_link "編集", match: :first
    end  

    fill_in "form_work_address_phones_0_number", with: "03-9999-9999" 
    check "form_work_address_phones_0_primary" 
    click_button "更新" 

    expect(page).to have_content "顧客情報を更新しました。" 

    #customer.reload 
    
    within("table.listing") do
      click_link "詳細", match: :first
    end

    #except(customer.home_address.phones.size).to eq(1)
    #except(customer.home_address.phones[0].number).to eq("03-9999-9999") 
    expect(page).to have_content "03-9999-9999"
  end 
end     