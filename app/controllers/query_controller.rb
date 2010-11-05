class QueryController < ApplicationController
  @@per_page = 25
  def index
    cnd = {}
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    qs = params[:query_string].to_s

    # q_value filter
    if params[:filter_value].to_f > 0.0
      cnd[params[:filter].to_sym] = (0.0)..(params[:filter_value].to_f)
    end

    # tissue
    if  (params[:assay] && params[:assay].length > 0)
      cnd[:assay_id] = params[:assay]
    end

    @probeset_stats = ProbesetStat.search(qs, :with => cnd, :page => page, :per_page => @@per_page, :include => [:probeset, :probeset_data], :order => "#{params[:filter]} ASC", :match_mode => :any)
    puts "@probeset_stats = #{@probeset_stats.length}"
    respond_to do |format|
      format.html 
      format.bgps { render :action => "index" , :layout => "biogps" }
      format.js {  render  :json => @probesets.to_json}
      format.xml { render :xml => @probesets.to_xml}
    end
  end
end
