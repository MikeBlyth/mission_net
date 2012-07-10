class CountriesController < ApplicationController
  helper :countries

  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :country do |config|
    config.columns = [:name, :nationality, :code]
    config.show.link = false
    config.update.link.confirm = "Are you sure you want to change this country?"
    list.sorting = {:name => 'ASC'}
    config.subform.columns.exclude :nationality, :code, :members
    config.subform.columns.exclude :nationality, :code, :members
  end


  def autocomplete
    @countries = Country.where("name LIKE ?", "#{params[:term]}%").select("id, name")
    @json_resp = []
    @countries.each do |c|
      # This method shows the user the labels (country names in this case), but then
      #   inserts the value (the country id in this case) into the input box
      #    @json_resp << {:label => c.name, :value => c.id}
      #
      # This method simply puts the country name into the input box. This means that the 
      #   controller must look it up before saving the record.
      @json_resp << c.name
    end

    respond_to do |format|
#      format.html
      format.js { render :json => @json_resp }
#      format.xml { render :xml => @countries }
    end
  end
end  
=begin
  
  # GET /countries
  # GET /countries.xml
  def index
    @countries = Country.find(:all, :order => :name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @countries }
    end
  end

  # GET /countries/1
  # GET /countries/1.xml
  def show
    @country = Country.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @country }
    end
  end

  # GET /countries/new
  # GET /countries/new.xml
  def new
    @country = Country.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @country }
    end
  end

  # GET /countries/1/edit
  def edit
    @country = Country.find(params[:id])
  end

  # POST /countries
  # POST /countries.xml
  def create
    @country = Country.new(params[:country])

    respond_to do |format|
      if @country.save
        format.html { redirect_to(@country, :notice => 'Country was successfully created.') }
        format.xml  { render :xml => @country, :status => :created, :location => @country }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @country.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /countries/1
  # PUT /countries/1.xml
  def update
    @country = Country.find(params[:id])

    respond_to do |format|
      if @country.update_attributes(params[:country])
        format.html { redirect_to(@country, :notice => 'Country was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @country.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /countries/1
  # DELETE /countries/1.xml
  def destroy
    @country = Country.find(params[:id])
    @country.destroy

    respond_to do |format|
      format.html { redirect_to(countries_url) }
      format.xml  { head :ok }
    end
  end
end
=end
