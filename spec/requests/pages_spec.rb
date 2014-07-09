require 'rails_helper'

RSpec.describe "Pages", :type => :request do

  let(:admin) { FactoryGirl.create(:admin) }
  let!(:home) { Post.find(Setting.get('home_page')) }
  let!(:post) { Post.where("post_type = 'page' AND (post_status = 'Published' OR post_status = 'Draft')").order("RANDOM()").first }
  before { sign_in(admin) }

  describe "GET /pages" do

    it "should show the homepage" do
      visit root_path
      expect(page).to have_content(home.post_title)
    end

  end

  describe "GET /pages/#id" do

    it "should show any page" do
      visit page_path(post.id)
      expect(page).to have_content(post.post_title)
    end

  end

end