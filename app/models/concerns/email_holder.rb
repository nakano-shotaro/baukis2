module EmailHolder 
  extend ActiveSupport::Concern 
  
  included do
    include StringNormalizer 

    # ★ prepend: true を追加して、最優先で実行させる
    before_validation(prepend: true) do 
      self.email = normalize_as_email(email) 
    end   
  
    validates :email, presence: true, "valid_email_2/email": true,
      uniqueness: { case_sensitive: false } 
  end  
end     