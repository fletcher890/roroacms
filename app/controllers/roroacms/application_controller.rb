module Roroacms

  class ApplicationController < ActionController::Base

    before_filter :configure_permitted_parameters, if: :devise_controller?
    before_filter :set_vars
    before_filter :check_setup
    before_filter :add_breadcrumb_fe
    before_filter :authorize_demo, :except => [:index, :show, :edit, :new]

    protect_from_forgery
    helper Roroacms::PrepcontentHelper
    helper Roroacms::ViewHelper
    helper Roroacms::MenuHelper
    helper Roroacms::SeoHelper
    helper Roroacms::CommentsHelper
    helper Roroacms::GeneralHelper
    include Roroacms::GeneralHelper
    include Roroacms::ViewHelper
    include Roroacms::PrepcontentHelper
    include Roroacms::SeoHelper

    private

    # Override the generic 404 page to use the 404 in the theme directory

    def render_404
      if File.exists?("#{Rails.root}/app/views/themes/#{current_theme}/error_404.html.erb")
        render( :template => "themes/#{current_theme}/error_404", :layout => 'layouts/roroacms/application', :status => :not_found) 
      else
        raise ActionController::RoutingError.new('404: Page was not found')
      end
    end

    # Get the current theme being used by the application

    def current_theme
      @theme_folder = Setting.get('theme_folder')
    end
    helper_method :current_theme


    # theme extension

    def get_theme_ext
      theme_yaml('view_extension')
    end
    helper_method :get_theme_ext


    # Return the current user data

    def current_user
      if !session["warden.user.admin.key"].blank?
        @current_admin ||= Admin.find_by_id(session["warden.user.admin.key"][0][0])
      else
        nil
      end
    end
    helper_method :current_user


    # globalize allows access to all of the given content from anywhere

    def gloalize(content)
      @content_multiple = content if content.class == ActiveRecord::Relation
      @content = content
    end

    # Return the current user logged in as admin data

    def current_admin
      @current_admin ||= current_user
    end


    # Returns the current access that is granted to the logged in admin. Allowing you to restrict necessary areas to certain types of user
    # currently there are only two user types (admin or editor)

    def current_admin_access

      if !@current_admin.nil?
        @current_admin.access_level
      else
        false
      end

    end

    # json encode/decode object variable - this is set here because it is used through out helpers/models/controllers

    def set_vars
      @json = ActiveSupport::JSON
      @breadcrumbs ||= []
    end


    # checks if the admin is logged in before anything else

    def authorize_admin
      redirect_to admin_login_path and return if current_user.nil?
    end


    # devise settings

    def after_sign_in_path_for(resource)
      
      set_sessions(session, current_user)
      admin_path

    end

    # check that the setup is complete if not redirect to the setup area

    def check_setup
       redirect_to setup_index_path and return if Setting.get('setup_complete') != 'Y' && params[:controller] != 'roroacms/setup' && session[:setup_complete].blank?
    end

    # add the home breadcrumb for the front end

    def add_breadcrumb_fe
      add_breadcrumb I18n.t("generic.home"), '/', :title => I18n.t("generic.home") if !params[:controller].include?('admin/')
    end

    # add a breadcrumb to the breadcrumb hash

    def add_breadcrumb(name, url = 'javascript:;', atts = {})
      hash = { name: name, url: url, atts: atts }
      @breadcrumbs << hash
    end

    # restricts any CRUD functions if you are logged in as the username of demo and you have demonstration mode turned on
    
    def authorize_demo
      if !request.xhr? && !request.get? && ( !current_user.blank? && current_user.username.downcase == 'demo' && Setting.get('demonstration_mode') == 'Y' )
        redirect_to :back, flash: { error: I18n.t('generic.demo_notification') } and return 
      end

      render :inline => 'demo' and return if params[:action] == 'save_menu' && !current_user.blank? && current_user.username.downcase == 'demo' && Setting.get('demonstration_mode') == 'Y'

    end

    # Adds an asterix to the field if it is required.
    
    def mark_required(object, attribute)  
      "*" if object.class.validators_on(attribute).map(&:class).include? ActiveModel::Validations::PresenceValidator  
    end 


    # protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :first_name, :last_name, :username, :access_level, :password_confirmation, :description) }
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :first_name, :last_name, :username, :access_level, :password_confirmation, :description) }
    end

  end

end