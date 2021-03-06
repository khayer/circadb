class TableController < ApplicationController
  helper :all # include all helpers, all the time
  protect_from_forgery

  def none

  end

  def write
    params[:match_mode] ||= 'gene_symbol'
    if params[:number_entries].to_i > 0
      # condition hash
      cnd = {}
      # page to fetch
      #current_page = params[:page].to_i > 0 ? params[:page].to_i : 1

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

      # phase
      params[:phase_range] = "0-40" if params[:phase_range] == nil #? params[:phase_range] : "0-40"
      pv = params[:phase_range].split("-")
      pv_lower = pv[0].to_f
      pv_upper = pv[1].to_f
      cnd[:jtk_lag] = (pv_lower)..(pv_upper)



      # query match mode
      params[:match_mode] ||= 'gene_symbol'
      params[:match_mode] = 'gene_symbol' if params[:match_mode] =~ /\W/
      @match_mode = params[:match_mode].to_sym

      if params[:match_mode] == 'gene_symbol' && params[:query_string]
        @new_query = ""
        if params[:query_string]
          @match_mode = "extended".to_sym
          params[:query_string].split(" ").each do |word|
            @new_query += "@gene_symbol #{word} | "
          end
          params[:query_string] = @new_query[0..-3]
        end
      end

      if params[:query_string]
        @probeset_stats = ProbesetStat.search(params[:query_string],
          #:page => current_page, :per_page => params[:number_entries].to_i,
          :with => cnd, :limit => params[:number_entries].to_i,
          :order => order, :match_mode => @match_mode,
          :include => [:probeset_data, :probeset, :probeset_stats])
      else
        @probeset_stats = ProbesetStat.search(#:page => current_page, :per_page => params[:number_entries].to_i,
          :with => cnd, :limit => params[:number_entries].to_i,
          :order => order,
          :include => [:probeset_data, :probeset, :probeset_stats])
      end


      if params[:query_string] && params[:match_mode] == 'gene_symbol'
        fields = params[:query_string].split("@gene_symbol")
        params[:query_string] = fields.join("\n").delete(" | ")
      end

      # if you want to log messages, look at the Rails logger functionality
      # puts "@probeset_stats = #{@probeset_stats.length}"
      if params[:number_entries].to_i > 0
        @k = "Probeset_ID,Symbol,Time,Values,JTKP,JTKQ,JTKperiod,JTKphase,Tissue\n"
        for i in 0...@probeset_stats.length
          probeset_stat = @probeset_stats[i]
          probeset = @probeset_stats[i].probeset
          next unless probeset
          gene_symbol = probeset.gene_symbol
          id = probeset.probeset_name
          probeset_data = probeset_stat.probeset_data
          time_points = probeset_data.time_points.delete("\"[]").gsub(/,/,';')
          data_points = probeset_data.data_points.delete("\"[]").split(",")
          data_points = data_points.map { |e| (e.to_f*100).round/100.to_f}
          data_points = data_points.join(";")
          jtkp = probeset_stat.jtk_p_value
          jtkq = probeset_stat.jtk_q_value
          jtkperiod = probeset_stat.jtk_period_length
          jtkphase = probeset_stat.jtk_lag
          tissue = probeset_stat.assay_name
          @k += "#{id},#{gene_symbol},#{time_points},#{data_points},#{jtkp},#{jtkq},#{jtkperiod},#{jtkphase},#{tissue}\n"
        end
      end

      respond_to do |format|
        format.html
        format.bgps do
          @unigene_id = params[:query_string]
          render :action => "write", :layout => "biogps"
        end
        format.js { render :json => @probeset_stats.to_json }
        format.xml { render :xml => @probeset_stats.to_xml }
      end

      send_data @k, :filename => 'query.csv', :type => 'text/csv' if @k
    end
  end
end

