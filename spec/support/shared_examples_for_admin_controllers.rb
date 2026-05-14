shared_examples "a protected admin controller" do |controller|
  let(:admin_host) { Rails.application.config.baukis2[:admin][:host] }
  let(:args) do
    {
      host: admin_host, 
      controller: controller
    }
  end

  describe "#index" do
    example "ログインフォームにリダイレクト" do
      get url_for(args.merge(action: :index))
      # 対策1: リダイレクト先のURLにも明示的にホストを指定する
      expect(response).to redirect_to(admin_login_url(host: admin_host))
    end
  end

  describe "#show" do
    example "ログインフォームにリダイレクト" do
      get url_for(args.merge(action: :show, id: 1))
      expect(response).to redirect_to(admin_login_url(host: admin_host))
    end
  end
end

shared_examples "a protected singular admin controller" do |controller|
  let(:admin_host) { Rails.application.config.baukis2[:admin][:host] }
  let(:args) do
    {
      host: admin_host,
      controller: controller
    }
  end

  describe "#show" do
    example "ログインフォームにリダイレクト" do
      get url_for(args.merge(action: :show))
      expect(response).to redirect_to(admin_login_url(host: admin_host))
    end
  end
end