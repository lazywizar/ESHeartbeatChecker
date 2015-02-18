require 'json'
require 'elasticsearch/transport'

class EsstatsmonitorController < ApplicationController
  # Alarm constants
  alarm_indices_index_time_in_millis = 5000



  def getstat
    #@ES_HOST="192.168.1.143:9200"
    @ES_HOST="ec2-23-22-8-207.compute-1.amazonaws.com:9200"

    #Stats we care about
    stats_we_care = ['name', 'indices', 'process', 'jvm', 'fs']
    indicies_stats_we_care_about = ['search', 'refresh', 'indexing', 'get', 'merges', 'search', 'indexing']
    process_stats_we_care_about = ['cpu']
    jvm_stats_we_care_about = ['mem']
    fs_stats_we_care_about = ['total']

    client = Elasticsearch::Client.new host: @ES_HOST
    response = client.perform_request 'GET', '_nodes/stats?pretty=true'

    responseJson = response.body

    searchHeartBeatCheck = client.search index: 'products_v2', type: 'product', routing: '1',
                             body: {
                                 query:{
                                      filtered: { query: { match_all: {}},
                                                  filter: { term: { brand_id: '1'}}}
                                  }
                             }

    Rails.logger.info searchHeartBeatCheck

    @product_avgQueryTime = searchHeartBeatCheck['took']
    @product_timedout = searchHeartBeatCheck['timed_out']
    @product_successful  = searchHeartBeatCheck['successful']

    node_stats = Array.new

    #Going through all nodes
    responseJson["nodes"].each do |nodes, value|
      node_stat_map = {}

      #GOing through all attributes for a node
      responseJson["nodes"][nodes].each do |node_key, node_value |
        if stats_we_care.include? node_key
          node_stat_map[node_key] = node_value
        end
      end
      node_stats << node_stat_map
    end

    #Rails.logger.info "Node Stats : #{node_stats}"

    node_stats.each do |node|
      #Now select only required stats in indices
      node["indices"].each do |key, value|
        #Rails.logger.info "Indicies key : #{key}"
        if !indicies_stats_we_care_about.include? key
          node["indices"].delete(key);
        end
      end
      checkIndicesAlarm(node["indices"])

      #Process
      node["process"].each do |key, value|
        #Rails.logger.info "Indicies key : #{key}"
        if !process_stats_we_care_about.include? key
          node["process"].delete(key);
        end
      end

      #jvm_stats_we_care_about
      node["jvm"].each do |key, value|
        #Rails.logger.info "Indicies key : #{key}"
        if !jvm_stats_we_care_about.include? key
          node["jvm"].delete(key);
        end
      end

      #fs_stats_we_care_about
      node["fs"].each do |key, value|
        #Rails.logger.info "Indicies key : #{key}"
        if !fs_stats_we_care_about.include? key
          node["fs"].delete(key);
        end
      end

    end

    #Rails.logger.info "Node Stats : #{node_stats}"

  end

  #####################################
  def checkIndicesAlarm(index)
    #indexing
    Rails.logger.info "index_time_in_millis : #{index["indexing"]["index_time_in_millis"]}"
    Rails.logger.info "delete_time_in_millis : #{index["indexing"]["delete_time_in_millis"]}"

    #get

    #search

    #merge

    #refresh


  end

  def searchHeartBeatCheck

  end



end
