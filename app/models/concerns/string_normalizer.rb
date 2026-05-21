require "nkf"

module StringNormalizer
  #extend ActiveSupport::Concern 

  def normalize_as_email(text)
    return nil if text.nil?
    # -w で入力もUTF-8として扱い、-Z1で半角化、-wでUTF-8出力
    normalized = NKF.nkf("-W -w -Z1", text.to_s).strip 
    normalized.delete(" ").downcase  
  end 
  
  def normalize_as_name(text)
    return nil if text.nil?
    NKF.nkf("-W -w -Z1", text.to_s).strip
  end 
  
  def normalize_as_furigana(text)
    return nil if text.nil?
    # カタカナ変換を追加
    NKF.nkf("-W -w -Z1 --katakana", text.to_s).strip
  end  
end    