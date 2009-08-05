class GlobalFilterController < ApplicationController
  unloadable

  helper IssuesHelper
  helper QueriesHelper
  
  def find_filter_issues
    retrieve_query
    
    if not params[:project].nil?
      @project = Project.find_by_identifier(params[:project])
    end
    
    @projects = User.current.projects
    ids = @projects.map{|p| p.id}
   
    sort = "#{Project.table_name}.id ASC,#{Issue.table_name}.status_id ASC,#{Issue.table_name}.priority_id DESC,#{Issue.table_name}.created_on DESC"
      
    if @query.valid? 
      if @project
        @query.project = @project
      end
      
      if not ids.empty?
        conditions = @query.statement+" AND #{Project.table_name}.id IN (%s)" % ids.join(',')
      else
        conditions = @query.statement
      end
    
      @issues = Issue.find(:all,
                         :include => [ :assigned_to, :status, :tracker, :project, :priority, :category, :fixed_version ],
                         :conditions => conditions,
                         :order => sort)
    end
    render :layout => !request.xhr?
  end
  
  # Retrieve query from session or build a new query
  def retrieve_query
    if !params[:query_id].blank?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = Query.find(params[:query_id], :conditions => cond)
      @query.project = @project
      session[:query] = {:id => @query.id, :project_id => @query.project_id}
    else
      if params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
        # Give it a name, required to be valid
        @query = Query.new(:name => "_")
        @query.project = @project
        if params[:fields] and params[:fields].is_a? Array
          params[:fields].each do |field|
            @query.add_filter(field, params[:operators][field], params[:values][field])
          end
        else
          @query.available_filters.keys.each do |field|
            @query.add_short_filter(field, params[field]) if params[field]
          end
        end
        session[:query] = {:project_id => @query.project_id, :filters => @query.filters}
      else
        @query = Query.find_by_id(session[:query][:id]) if session[:query][:id]
        @query ||= Query.new(:name => "_", :project => @project, :filters => session[:query][:filters])
        @query.project = @project
      end
    end
  end
end