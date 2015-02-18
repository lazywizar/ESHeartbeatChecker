require 'json'
require 'elasticsearch/transport'

class EsstatsmonitorController < ApplicationController

  def getstat
    #@ES_HOST="192.168.1.143:9200"
    @ES_HOST="ec2-23-22-8-207.compute-1.amazonaws.com:9200"

    client = Elasticsearch::Client.new host: @ES_HOST
    response = client.perform_request 'GET', '_nodes/stats?pretty=true'

    responseJson = response.body

    node_stats = Array.new
    @stats = Array.new

    #Going through all nodes
    responseJson["nodes"].each do |nodes, value|
        node_stat_map = {}
        node_stat_map['name'] = value["name"]
        node_stat_map['cpu_percentage'] = value["process"]["cpu"]["percent"]
        node_stat_map['heap_used_percent'] = value["jvm"]["mem"]["heap_used_percent"]
        node_stat_map['free_in_bytes'] = value["fs"]["total"]["free_in_bytes"].to_i / 1000000
        node_stat_map['total_in_bytes'] = value["fs"]["total"]["total_in_bytes"].to_i / 1000000
        node_stat_map['index_time_in_millis'] = value["indices"]["indexing"]["index_time_in_millis"]
        node_stat_map['delete_time_in_millis'] = value["indices"]["indexing"]["delete_time_in_millis"]

        if node_stat_map['cpu_percentage'] > 300 || node_stat_map['heap_used_percent'] > 90 || node_stat_map['free_in_bytes'] < 10000
          node_stat_map['status'] = "red"
        else
          node_stat_map['status'] = "green"
        end

        node_stats << node_stat_map
        @stats << node_stat_map
    end

    @product_avgQueryTime = HeartbeatCheckerTask.check

    #Rails.logger.info "Node Stats : #{node_stats}"
    #@stats = node_stats

  end

end
