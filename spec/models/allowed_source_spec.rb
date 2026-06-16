require 'rails_helper'

RSpec.describe AllowedSource, type: :model do
  #pending "add some examples to (or delete) #{__FILE__}"
  
  describe "#ip_address=" do 
    context "引数に「127.0.0.1」を与えた場合" do 
      let(:src) { AllowedSource.new(namespace: "staff", ip_address: "127.0.0.1") }

      example '正しく分割され、ワイルドカードではないこと' do
        expect(src.octet1).to eq(127)
        expect(src.octet2).to eq(0)
        expect(src.octet3).to eq(0)
        expect(src.octet4).to eq(1)
        expect(src).not_to be_wildcard
        expect(src).to be_valid 
      end 
    end   
    
    context "引数に「192.168.0.*」を与えた場合" do 
      let(:src) { AllowedSource.new(namespace: "staff", ip_address: "192.168.0.*") }

      example '正しく分割され、ワイルドカードであること' do
        expect(src.octet1).to eq(192)
        expect(src.octet2).to eq(168)
        expect(src.octet3).to eq(0)
        expect(src.octet4).to eq(0)
        expect(src).to be_wildcard
        expect(src).to be_valid 
      end   
    end 

    context "引数に不正な文字列を与えた場合" do 
      let(:src) { AllowedSource.new(namespace: "staff", ip_address: "A.B.C.D") }

      example '無効であること' do
        expect(src).not_to be_valid 
      end  
    end  
  end
end
