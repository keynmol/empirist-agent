require 'sinatra'
require 'faraday'
require 'yaml'

config = YAML.load_file('config.yml')
connection=Faraday.new("http://#{config['empirist_server']['host']}:#{config['empirist_server']['port']}") do |f|
								  f.request :multipart
								  f.request :url_encoded
								  f.adapter :net_http # This is what ended up making it work
								end

Dir.mkdir(config['cache_folder']) unless File.exists?(config['cache_folder'])

get '/server' do
	connection.build_url.to_s
end

get '/local_cache' do
	config["cache_folder"]
end

get '/find_trial/*' do
	base_url=params["splat"][0]
	redirect connection.build_url("find_trial/#{base_url}", params.reject{|k,v| ["splat","captures"].include? k})
end

get '/plot/*' do
	base_url=params["splat"][0]
	redirect connection.build_url("plot/#{base_url}", params.reject{|k,v| ["splat","captures"].include? k})
end

get '/annotation/:id' do
	redirect connection.build_url("annotation/#{params['id']}")
end


get '/synchronise_plot' do
	trial_id=params["id"]
	plot_name=params["plot"]

	plotfile=File.join config["cache_folder"], "#{trial_id}-#{plot_name}.pdf"
	
	if File.exists?(plotfile)
					puts "uploading path: #{plotfile}, filesize: #{File.size(plotfile)}" 
					
					params={file: Faraday::UploadIO.new(plotfile, 'application/pdf'),
							plot: plot_name,
							trial_id: trial_id}

					
					connection.post '/upload_plot', params
	end
	
end

get '/dataset/*' do
	# trial_query={__project: params["project_name"], __experiment: params["experiment_name"]}
	# trial_query.merge!(params.reject {|k,v| ["experiment_name","project_name","format", "splat","captures","data_stream"].include? k })
	# trial_query[:__success]=1

	# data_stream=params["data_stream"] || default

	# trials=trials_collection.find(trial_query).sort(:__timestamp => :desc)
	# if trials.count > 0
	# 	latest_trial = trials.first
	# 	id=latest_trial["_id"]
	# 	filename="#{id.to_s}-#{data_stream}.csv"
	# 	path=File.join(config["cache_folder"], filename)
		
	# 	if File.exists? path
	# 		send_file path, filename: filename, type: "text/csv"
	# 	end
	# else
	# 	404
	# end 

	# TODO: Add caching here!
	
	base_url=params["splat"][0]
	redirect connection.build_url("dataset/#{base_url}", params.reject{|k,v| ["splat","captures"].include? k})
end