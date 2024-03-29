class Admin::UsersController < Admin::BaseController
  
  %w(email login).each do |attr|
    in_place_edit_for :user, attr.to_sym
  end
  
  def toggle_role
    @user = User.find(params[:id])
    role = Role.find_by_name(params[:role])
    if @user.roles.include?(role)
      @user.roles.delete(role)
      flash[:notice] = t('admin.users.revoke_role', :role => role.name)
    else
      @user.roles << role
      @user.save
      flash[:notice] = t('admin.users.grant_role', :role => role.name)
    end
    if request.env["HTTP_REFERER"].present?
      redirect_to :back
    else
      redirect_to admin_user_path(@user)
    end
  end
  
  def search
    # Basic Search with pagination
    @users = User.search(params[:search], params[:page])
    render :index
  end
  
  def reset_password
    @user = User.find(params[:id])
    @user.reset_password!
    
    flash[:notice] = t("admin.users.send_password_mail")
    redirect_to admin_user_path(@user)
  end
  
  def filter
    case params[:by]  
    when "roles"
      @users = User.role_users(params[:name]).page(params[:page])

    when "pending"  
      @users = User.paginate :conditions => {:state => 'pending'}, :page => params[:page]

    when "suspended"  
      @users = User.paginate :conditions => {:state => 'suspended'}, :page => params[:page]

    when "active"  
      @users = User.paginate :conditions => {:state => 'active'}, :page => params[:page]

    when "deleted"  
      @users = User.paginate :conditions => {:state => 'deleted'}, :page => params[:page]

    when "all"  
      @users = User.paginate :page => params[:page]

    else
      
    end
    render :action => 'index'
  end
  
  def pending
    @users = User.paginate :conditions => {:state => 'pending'}, :page => params[:page]
    render :action => 'index'
  end
  
  def suspended
    @users = User.paginate :conditions => {:state => 'suspended'}, :page => params[:page]
    render :action => 'index'
  end
  
  def active
    @users = User.paginate :conditions => {:state => 'active'}, :page => params[:page]
    render :action => 'index'
  end
  
  def deleted
    @users = User.paginate :conditions => {:state => 'deleted'}, :page => params[:page]
    render :action => 'index'
  end
  
  def activate
    @user = User.find(params[:id])
    @user.activate!
    redirect_to admin_users_path
  end
  
  def suspend
    @user = User.find(params[:id])
    @user.suspend! 
    redirect_to admin_users_path
  end

  def unsuspend
    @user = User.find(params[:id])
    @user.unsuspend! 
    redirect_to admin_users_path
  end

  def purge
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_url
  end
  
  # DELETE /admin_users/1
  # DELETE /admin_users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.delete!

    redirect_to admin_users_path
  end

  # GET /admin_users
  # GET /admin_users.xml
  def index
    @users = User.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /admin_users/1
  # GET /admin_users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end    
  end
  
  # GET /admin_users/new
  # GET /admin_users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # POST /admin/users
  def create
    @user = User.new(params[:user])
   # debugger
    respond_to do |format|
      if @user.save
        flash[:notice] = t("admin.users.create_success");
        format.html { redirect_to(admin_user_url(@user)) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to :action => :show, :id => params[:id] }
      else
        format.html { render :action => :edit }
      end
    end
  end
  
end
