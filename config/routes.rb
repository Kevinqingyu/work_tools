Rails.application.routes.draw do
  root "events#index"
  resources :events do
    collection do
      get :export        # 导出表格
      get :import_events # 导入表格页面
      get :trans_to_zh   # 开始翻译
      post :import       # 导入
    end
  end
end
