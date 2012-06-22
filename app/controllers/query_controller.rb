class QueryController < ApplicationController
  @@per_page = 10

  def index
    # condition hash
    cnd = {}
    # page to fetch
    current_page = params[:page].to_i > 0 ? params[:page].to_i : 1
    # q_value filter
    params[:filter] ||= "jtk_p_value"
    fv = params[:filter_value].to_f > 0.0 ? params[:filter_value].to_f : 0.05
    cnd[params[:filter].to_sym] = (0.0)..(fv)

    # tissue
    cnd[:assay_id] = params[:assays] if params[:assays]
    if params[:query_string].to_s.empty? 
      params[:query_string] = nil
    end

    if params[:query_string]
      @probeset_stats = ProbesetStat.search(params[:query_string].strip!,
        :page => current_page, :per_page => @@per_page, :with => cnd,
        :order => "#{params[:filter]} ASC", :match_mode => :any,
        :include => [:probeset_data, :probeset])
    else
      @probeset_stats = ProbesetStat.search(:page => current_page, :per_page => @@per_page, :with => cnd,
        :order => "#{params[:filter]} ASC",
        :include => [:probeset_data, :probeset])
    end
    puts "@probeset_stats = #{@probeset_stats.length}"
    respond_to do |format|
      format.html
      format.bgps do
        @unigene_id = params[:query_string]
        render :action => "index", :layout => "biogps"
      end
      format.js { render :json => @probeset_stats.to_json }
      format.xml { render :xml => @probeset_stats.to_xml }
    end
  end

  def help
  end

  def about
  end
end
