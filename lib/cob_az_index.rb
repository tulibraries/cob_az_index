# frozen_string_literal: true

require "cob_az_index/version"
require "traject"
require "httparty"

module CobAzIndex
  module CLI
    def self.ingest(ingest_path: nil, ingest_string: "")
      indexer = Traject::Indexer::MarcIndexer.new("solr_writer.commit_on_close": true)
      indexer.load_config_file("#{File.dirname(__FILE__)}/cob_az_index/indexer_config.rb")

      if ingest_path
        ingest_string = open(ingest_path).read
      end

      indexer.writer.delete(query: "*:*")
      indexer.process(StringIO.new(ingest_string))
    end

    def self.pull(client_id: ENV["AZ_CLIENT_ID"], client_secret: ENV["AZ_CLIENT_SECRET"])
      endpoint = "https://lgapi-us.libapps.com/1.2/oauth/token"

      response = HTTParty.post(endpoint, body: { client_id: client_id, client_secret: client_secret, grant_type: "client_credentials" })
      cred = JSON.parse(response)

      endpoint = "https://lgapi-us.libapps.com/1.2/az"
      token = cred["access_token"]
      response = HTTParty.get(endpoint, headers: { Authorization: "Bearer #{token}" }, query: { expand: "subjects,icons,friendly_url,az_types,az_props,permitted_uses" })
      response.body
    end
  end
end
