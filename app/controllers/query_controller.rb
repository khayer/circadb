class QueryController < ApplicationController
  @@per_page = 10

  def index
    # condition hash
    cnd = {}
    # page to fetch
    current_page = params[:page].to_i > 0 ? params[:page].to_i : 1

    # q_value filter
    params[:filter] ||= "jtk_p_value"
    if ProbesetStat.pval_filters.flatten.include?(params[:filter])
      order = "#{params[:filter]} ASC"
    else
      order = "jtk_p_value ASC"
    end
    fv = params[:filter_value].to_f > 0.0 ? params[:filter_value].to_f : 0.05
    cnd[params[:filter].to_sym] = (0.0)..(fv)

    # tissue
    cnd[:assay_id] = params[:assays] if params[:assays]
    if params[:query_string].to_s.strip.empty?
      params[:query_string] = nil
    end
    # query match mode
    params[:match_mode] ||= 'any'
    @match_mode = params[:match_mode].to_sym

    if params[:query_string]
      @probeset_stats = ProbesetStat.search(params[:query_string],
        :page => current_page, :per_page => @@per_page, :with => cnd,
        :order => order, :match_mode => @match_mode,
        :include => [:probeset_data, :probeset, :probeset_stats])
    else
      @probeset_stats = ProbesetStat.search(:page => current_page, :per_page => @@per_page, :with => cnd,
        :order => order,
        :include => [:probeset_data, :probeset, :probeset_stats])
    end

    # if you want to log messages, look at the Rails logger functionality
    # puts "@probeset_stats = #{@probeset_stats.length}"
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
end
