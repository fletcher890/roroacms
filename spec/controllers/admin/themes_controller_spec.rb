require 'rails_helper'

RSpec.describe Admin::ThemesController, :type => :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  before { sign_in(admin) }

  describe "GET #index" do

    before(:each) do
      get :index
    end

    it "should set the current theme used by roroa" do
      expect(assigns(:current)).to_not be_nil
    end

    it "should render the :index template" do
      expect(response).to render_template :index
    end

  end

  describe "POST #create" do

    before(:each) do
      post :create, theme: 'roroa1'
    end

    it "should reset the current theme" do
      expect(Setting.get('theme_folder')).to eq('roroa1')
    end

    it "should redirect to themes#index" do
      expect(response).to redirect_to admin_themes_path
    end

  end

  describe "DELETE #destroy" do

    before(:each) do
      Dir.mkdir("#{Rails.root}/app/views/theme/testing") unless File.exists?("#{Rails.root}/app/views/theme/testing")
      delete :destroy, id: 'testing'
    end

    it "should delete the given theme" do
      expect(File.directory?("#{Rails.root}/app/views/theme/testing")).to be_falsey
    end

    it "should redirect to themes#index" do
      expect(response).to redirect_to admin_themes_path
    end

  end

end
