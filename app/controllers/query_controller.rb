class QueryController < ApplicationController
  @per_page = 50
  @k ||= nil

  def download
    send_data @k, :filename => 'query.csv', :type => 'text/csv'
  end

  def index
    # condition hash
    cnd = {}
    # page to fetch
    current_page = params[:page].to_i > 0 ? params[:page].to_i : 1

    # q_value filter
    params[:filter] ||= "jtk_q_value"
    if params[:query]
      params[:filter] = params[:query][:filter]
    end
    #params[:filter]

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

    # output mode
    params[:output_mode] ||= 'normal'
    @output_mode = params[:output_mode].to_sym

    # query match mode
    params[:match_mode] ||= 'gene_symbol'

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
        :page => current_page, :per_page => @per_page, :with => cnd,
        :order => order, :match_mode => @match_mode,
        :include => [:probeset_data, :probeset, :probeset_stats])
    else
      @probeset_stats = ProbesetStat.search(:page => current_page,
        :per_page => @per_page, :with => cnd,
        :order => order,
        :include => [:probeset_data, :probeset, :probeset_stats])
    end

    if params[:number_entries].to_i > 0
      if params[:query_string]
        probeset_stats = ProbesetStat.search(params[:query_string],
        :page => current_page, :per_page => params[:number_entries].to_i,
        :with => cnd,
        :order => order, :match_mode => @match_mode,
        :include => [:probeset_data, :probeset, :probeset_stats])
      else
        probeset_stats = ProbesetStat.search(:page => current_page,
          :per_page => params[:number_entries].to_i, :with => cnd,
          :order => order,
          :include => [:probeset_data, :probeset, :probeset_stats])
      end
      #filename = "#{RAILS_ROOT}/test.nina.txt"
      #logger.debug "Person attributes hash: #{@person.attributes.inspect}"
     #logger.info "Filename: #{filename}"
      #logger.fatal "Terminating application, raised unrecoverable error!!!"
      #puts filename
      #if params[:query_string]
      #  xprobeset_stats = ProbesetStat.search(params[:query_string],
      #    :page => current_page, :per_page => params[:number_entries].to_i,
      #    :with => cnd,
      #    :order => order, :match_mode => @match_mode,
      #    :include => [:probeset_data, :probeset, :probeset_stats])
      #else
      #  xprobeset_stats = ProbesetStat.search(:page => current_page, :per_page => params[:number_entries].to_i,
      #    :with => cnd,
      #    :order => order,
      #    :include => [:probeset_data, :probeset, :probeset_stats])
      #end
      if params[:filter] =~ /^jtk/
        @k = "Probeset_ID,Symbol,Time,Values,JTKP,JTKQ,JTKperiod,JTKphase,Tissue\n"
        for i in 0...params[:number_entries].to_i
          probeset_stat = probeset_stats[i]
          break unless probeset_stat
          probeset = probeset_stats[i].probeset
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
      elsif params[:filter] =~ /^cosopt/
        @k = "Probeset_ID,Symbol,Time,Values,LombScargle_P,LombScargle_Q,LombScargle_period,LombScargle_phase,Tissue\n"
        for i in 0...params[:number_entries].to_i
          probeset_stat = probeset_stats[i]
          break unless probeset_stat
          probeset = probeset_stats[i].probeset
          next unless probeset
          gene_symbol = probeset.gene_symbol
          id = probeset.probeset_name
          probeset_data = probeset_stat.probeset_data
          time_points = probeset_data.time_points.delete("\"[]").gsub(/,/,';')
          data_points = probeset_data.data_points.delete("\"[]").split(",")
          data_points = data_points.map { |e| (e.to_f*100).round/100.to_f}
          data_points = data_points.join(";")
          jtkp = probeset_stat.cosopt_p_value
          jtkq = probeset_stat.cosopt_q_value
          jtkperiod = probeset_stat.cosopt_period_length
          jtkphase = probeset_stat.cosopt_phase
          tissue = probeset_stat.assay_name
          @k += "#{id},#{gene_symbol},#{time_points},#{data_points},#{jtkp},#{jtkq},#{jtkperiod},#{jtkphase},#{tissue}\n"
        end
      end



      #File.delete(filename)
    else
      @k = nil
    end

    if params[:query_string] && params[:match_mode] == 'gene_symbol'
      fields = params[:query_string].split("@gene_symbol")
      params[:query_string] = fields[1..-1].join("\n").delete(" | ")
    end

    #download(k) if k


    # if you want to log messages, look at the Rails logger functionality
    # puts "@probeset_stats = #{@probeset_stats.length}"
    respond_to do |format|
      format.html {render_to_string}
      format.bgps do
        @unigene_id = params[:query_string]
        render_to_string :action => "index", :layout => "biogps"
      end
      format.js { render_to_string  :json => @probeset_stats.to_json }
      format.xml { render_to_string  :xml => @probeset_stats.to_xml }
    end

    send_data @k, :filename => 'query.csv', :type => 'text/csv' if @k
  end

end

