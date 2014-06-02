class Admin::TermsController < AdminController

	# displays all the current categories and creates a new category object for creating a new one

	def categories
		# add breadcrumb and set title
		add_breadcrumb I18n.t("controllers.admin.terms.categories.title"), :admin_article_categories_path, :title => I18n.t("controllers.admin.terms.categories.breadcrumb_title")
		@title = I18n.t("controllers.admin.terms.categories.title")
		@type = 'category'

		# render view template as it is the same as the tag view
		render 'view'
	end


	# displays all the current tags and creates a new category object for creating a new one

	def tags
		# add breadcrumb and set title
		add_breadcrumb I18n.t("controllers.admin.terms.tags.title"), :admin_article_tags_path, :title => I18n.t("controllers.admin.terms.tags.breadcrumb_title")
		@title = I18n.t("controllers.admin.terms.tags.title")
		@type = 'tag'
		# render view template as it is the same as the category view
		render 'view'
	end


	# create tag or category - this is set within the form

	def create
		@category = Term.new(term_params)
		
		# deal with any abnormalaties which just makes sure there are "-" instead of spaces within the slug
		@category.deal_with_abnormalaties

		respond_to do |format|

		  if @category.save

		  	@term_anatomy = @category.create_term_anatomy(:taxonomy => params[:type_taxonomy])
		  	Term.update_slug_for_subcategories(@category.id, @category.structured_url, true)
		    format.html { redirect_to send(Term.get_redirect_url(params)), notice: I18n.t("controllers.admin.terms.create.flash.success", term: Term.get_type_of_term(params)) }

		  else

		  	flash[:error] = I18n.t("controllers.admin.terms.create.flash.error")
		    format.html { redirect_to send(Term.get_redirect_url(params)) }

		  end

		end
	end


	# get the term record to be edited

	def edit 
		@category = Term.find(params[:id])
		@title = edit_title()
		@type = @category.term_anatomy.taxonomy
	end


	# update the term record with the given parameters

	def update
	    @category = Term.find(params[:id])

	    # redirect url will be different for either tag or category
	   	old_url = @category.structured_url

	    respond_to do |format|
	    	# deal with abnormalaties - update the structure url 
			if @category.update_attributes(term_params)
			    Term.update_slug_for_subcategories(@category.id, old_url, true)
				format.html { redirect_to edit_admin_term_path(@category), notice: I18n.t("controllers.admin.terms.update.flash.success", term: Term.get_type_of_term(params)) }
			else
				format.html { 
					@title = edit_title()
					render action: "edit" 
				}
			end

	    end
	end


	# delete the term

	def destroy
		# return url will be different for either tag or category
	    session[:return_to] = request.referer

	    @term = Term.find(params[:id])
	    @term.destroy

	    respond_to do |format|
	      format.html { redirect_to "#{session[:return_to]}", notice: I18n.t("controllers.admin.terms.destroy.flash.success") }
	    end
	end


	# Takes all of the checked options and updates them with the given option selected. 
	# The options for the bulk update in pages area are:-
	# - Delete

	def bulk_update
		notice = Term.bulk_update params
		redirect_url = Term.get_redirect_url params

		respond_to do |format|
	      format.html { redirect_to send(redirect_url), notice: notice }
	    end
	end
	

	private 

	# set the title and breadcrumbs for the edit screen

	def edit_title

		if @category.term_anatomy.taxonomy == 'category' 
			add_breadcrumb I18n.t("controllers.admin.terms.edit_title.category.breadcrumb"), :admin_article_categories_path, :title => I18n.t("controllers.admin.terms.edit_title.category.breadcrumb_title")
			add_breadcrumb I18n.t("controllers.admin.terms.edit_title.category.title")
			@title = I18n.t("controllers.admin.terms.edit_title.category.title")
		else
			add_breadcrumb I18n.t("controllers.admin.terms.edit_title.tag.breadcrumb"), :admin_article_tags_path, :title => I18n.t("controllers.admin.terms.edit_title.tag.breadcrumb_title")
			add_breadcrumb I18n.t("controllers.admin.terms.edit_title.tag.title")
			@title = I18n.t("controllers.admin.terms.edit_title.tag.title")
		end

		return @title

	end
	
	
	# Strong parameter

	def term_params
		if !session[:admin_id].blank?
			params.require(:term).permit(:name, :parent, :slug, :structured_url, :description, :term_group)
		end
	end

end