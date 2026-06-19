class Admin::AllowedSourcesDeleter 
  def delete(params) 
    if params && params[:allowed_sources].kind_of?(ActionController::Parameters) 
      ids = [] 
      
      params[:allowed_sources].values.each do |hash| 
        if hash[:_destroy] == "1" 
          ids << hash[:id]   
        end     
      end 
      
      if ids.present? 
        AllowedSource.where(namespace: "staff", id: ids).delete_all 
        return true # 削除を実行した場合は true を返す
      end   
    end  
    false # 削除されなかった（または対象パラメータが無かった）場合は false を返す  
  end     
end     