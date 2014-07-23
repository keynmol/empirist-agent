require 'sinatra'
require 'faraday'
require 'yaml'

config = YAML.load_file('config.yml')
connection=Faraday.new("http://#{config['empirist_server']['host']}:#{config['empirist_server']['port']}")


get '/server' do
	connection.build_url.to_s
end

get '/local_cache' do
	config["cache_folder"]
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