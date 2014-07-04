require 'rails_helper'

RSpec.describe "Admin::Articles", :type => :request do

	let(:admin) { FactoryGirl.create(:admin) }
  	before { sign_in(admin) }
	let!(:article) { FactoryGirl.create(:post, post_type: 'post') }

  	describe "GET /admin/articles" do

  		it "should show articles" do 
  			visit admin_articles_path
  			expect(page).to have_content('Articles')
  			expect(page).to have_content(article.post_title)
  		end

  		it "should have a button to allow user to create new article" do 
  			visit admin_articles_path
  			find('#add-new-article').click
  			expect(current_path).to eq(new_admin_article_path)
  			expect(page).to have_content('Create New Article')
  		end

  	end


  	describe "GET /admin/articles/new" do

	  	let(:article) { FactoryGirl.build(:post, post_type: 'post') } 

	  	it "should create new article" do 
	  		visit new_admin_article_path
	  		fill_in 'post_post_title', :with => article.post_title
	  		fill_in 'post_post_slug', :with => article.post_slug
	  		click_button 'Save'
	  		expect(current_path).to eq(admin_articles_path)
	  		expect(page).to have_content('success')
	  	end

	  	it "should not allow title to be blank" do 
	  		visit new_admin_article_path
	  		click_button 'Save'
	  		expect(current_path).to eq(admin_articles_path)
	  		expect(page).to have_selector('.help-block.error')
	  		expect(page).to have_content('Title is required')
	  		expect(page).to have_content('Url is required')
	  	end

	  	it "should have the option to add categories" do 
	  		visit new_admin_article_path
	  		expect(page).to have_content('Tags & Categories')
	  	end

	  	it "should have the ability to add search engine data" do 
	  		article = FactoryGirl.build(:post, post_type: 'post')
	  		visit new_admin_article_path
	  		fill_in 'post_post_title', :with => article.post_title
	  		fill_in 'post_post_seo_title', :with => article.post_title
	  		click_button 'Save'
	  		expect(current_path).to eq(admin_articles_path)
	  		expect(page).to have_content('success')
	  		expect(page).to have_content(article.post_title)
	  	end

  	end

  	describe "PUT /admin/article/#id" do 

  		it "should update the article" do 
  			visit edit_admin_article_path(article.id)
  			fill_in 'post_post_content', :with => Faker::Lorem.paragraph(5) 
  			click_button 'Save'
  			expect(current_path).to eq(edit_admin_article_path(article.id))
  			expect(page).to have_content('Success')
  		end

  		it "should not allow you to update the article with no title" do 
  			visit edit_admin_article_path(article.id)
  			fill_in 'post_post_title', :with => ''
  			click_button 'Save'
  			expect(current_path).to eq(admin_article_path(article.id))
  			expect(page).to have_selector('.help-block.error')
	  		expect(page).to have_content('Title is required')
  		end

  	end

end