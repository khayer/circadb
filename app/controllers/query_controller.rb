class QueryController < ApplicationController
  @@per_page = 25
  def index
    cnd = {}
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    qs = params[:query_string].to_s

    # q_value filter
    if params[:cosopt_q_value].to_f > 0.0
      cnd[:cosopt_q_value] = (0.0)..(params[:cosopt_q_value].to_f)
    end

    # tissue
    if  (params[:assay].to_i > 0)
      cnd[:assay_id] = params[:assay].to_i
    end

    @probeset_stats = ProbesetStat.search(qs, :with => cnd, :page => page, :per_page => @@per_page, :include => [:probeset, :probeset_data], :order => "jtk_q_value ASC", :match_mode => :any)

    respond_to do |format|
      format.html 
      format.bgps { render :action => "index" , :layout => "biogps" }
      format.js {  render  :json => @probesets.to_json}
      format.xml { render :xml => @probesets.to_xml}
    end
  end
end
