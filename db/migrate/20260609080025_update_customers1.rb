class UpdateCustomers1 < ActiveRecord::Migration[7.1]
  #def change
  #end

  def up 
    # ⚠️ カラムが存在しない場合は、ここで強制的に追加する
    unless column_exists?(:customers, :birth_year)
      add_column :customers, :birth_year, :integer
      add_column :customers, :birth_month, :integer
      add_column :customers, :birth_mday, :integer
      
      # インデックスも未作成ならここで追加する
      unless index_name_exists?(:customers, "index_customers_on_birth_year_and_birth_month_and_birth_mday")
        add_index :customers, [ :birth_year, :birth_month, :birth_mday ]
      end
    end

    execute(%q{
      UPDATE customers SET birth_year = EXTRACT(YEAR FROM birthday), 
        birth_month = EXTRACT(MONTH FROM birthday),
        birth_mday = EXTRACT(DAY FROM birthday)
        WHERE birthday IS NOT NULL
    })
  end 
  
  def down 
    #execute(%q{
      #UPDATE customers SET birth_year = NULL, 
        #birth_month = NULL,
        #birth_mday = NULL
    #}) 
    
    # ロールバック時は、upで追加したカラムとインデックスを安全に削除する
    if column_exists?(:customers, :birth_year)
      remove_index :customers, [ :birth_year, :birth_month, :birth_mday ] if index_exists?(:customers, [ :birth_year, :birth_month, :birth_mday ])
      remove_column :customers, :birth_year, :integer
      remove_column :customers, :birth_month, :integer
      remove_column :customers, :birth_mday, :integer
    end
  end   
end
