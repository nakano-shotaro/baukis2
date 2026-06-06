class Staff::CustomerForm 
  include ActiveModel::Model 

  attr_accessor :customer, :inputs_home_address, :inputs_work_address  
  #delegate :persisted?, :save, to: :customer 
  delegate :persisted?, to: :customer 

  def initialize(customer = nil) 
    @customer = customer
    @customer ||= Customer.new(gender: "male") 
    (2 - @customer.personal_phones.size).times do 
      @customer.personal_phones.build 
    end   
    self.inputs_home_address = @customer.home_address.present? 
    self.inputs_work_address = @customer.work_address.present?
    @customer.build_home_address unless @customer.home_address 
    @customer.build_work_address unless @customer.work_address 
    (2 - @customer.home_address.phones.size).times do 
      @customer.home_address.phones.build 
    end   
  end 
  
  def assign_attributes(params = {}) 
    @params = params
    self.inputs_home_address = params[:inputs_home_address] == "1" 
    self.inputs_work_address = params[:inputs_work_address] == "1"

    customer.assign_attributes(customer_params)

    phones = phone_params(:customer).fetch(:phones, {})  
    
    # 既存の personal_phones を配列としてローカル変数に退避させる
    # (動的なソートや破壊フラグによるActiveRecord内部の配列崩れを防ぐため)
    current_phones = customer.personal_phones.to_a
    
    2.times do |index| 
      attributes = phones[index.to_s] 
      # 既存のオブジェクトがあればそれを使い、なければ新しく build する
      phone = current_phones[index] || customer.personal_phones.build
      
      # 【重要】親オブジェクトを明示的に紐付ける
      phone.customer = customer 

      if attributes && attributes[:number].present? 
        phone.assign_attributes(attributes) 
      else 
        # すでに保存済みのデータなら削除マーク、未保存ならコレクションから安全に削除
        if phone.persisted?
          phone.mark_for_destruction
        else
          customer.personal_phones.delete(phone)
        end
      end   
    end

    #customer.personal_phones.size.times do |index| 
      #attributes = phones[index.to_s] 
      #if attributes && attributes[:number].present? 
        #customer.personal_phones[index].assign_attributes(attributes) 
      #else 
        #customer.personal_phones[index].mark_for_destruction  
      #end   
    #end   

    if inputs_home_address
      customer.home_address.assign_attributes(home_address_params)
      phones = phone_params(:home_address).fetch(:phones)

      customer.home_address.phones.size.times do |index| 
        attributes = phones[index.to_s] 
        if attributes && attributes[:number].present? 
          customer.home_address.phones[index].assign_attributes(attributes)
        else 
          customer.home_address.phones[index].mark_for_destruction 
        end     
      end   
    else 
      customer.home_address.mark_for_destruction   
    end 

    if inputs_work_address
      customer.work_address.assign_attributes(work_address_params)
    else 
      customer.work_address.mark_for_destruction    
    end 
    p phones   
  end 

  def valid? 
    # 顧客、自宅住所、勤務先住所、および電話番号（削除マーク付き以外）のすべてを検証
    valid_phones = customer.personal_phones.reject(&:marked_for_destruction?).map(&:valid?).all?

    [ customer, customer.home_address, customer.work_address ]
      .map(&:valid?).all? && valid_phones 
  end   

  def save 
    if valid?
      ActiveRecord::Base.transaction do 
        # 削除マークがついている電話番号を物理削除、それ以外を保存
        customer.personal_phones.each do |phone|
          if phone.marked_for_destruction?
            phone.destroy!
          else
            phone.save!
          end
        end

        customer.save!
        customer.home_address.save!
        customer.work_address.save!
      end 
      true 
    else 
      false   
    end    
    #customer.save  
  end   

  private def customer_params 
    @params.require(:customer).except(:phones).permit( 
      :email, :password,
      :family_name, :given_name, :family_name_kana, :given_name_kana,
      :birthday, :gender
    )
  end  

  private def home_address_params 
    @params.require(:home_address).except(:phones).permit(
      :postal_code, :prefecture, :city, :address1, :address2
    )
  end 

  private def work_address_params 
    @params.require(:work_address).permit(
      :postal_code, :prefecture, :city, :address1, :address2,
      :company_name, :division_name
    )
  end 

  #private def phone_params(record_name) 
    #@params.require(record_name)
      #.slice(:phones).permit(phones: [ :number, :primary ]) 
  #end
  
  private def phone_params(record_name) 
    @params.require(record_name)
      .slice(:phones).permit(phones: [ "0", "1" ]
        .to_h { |key| [ key, [:number, :primary]]}) 
  end 
end     