# frozen_string_literal: true

require "traject_plus"
require "traject_plus/json_reader.rb"
require "traject_plus/macros"
require "traject_plus/macros/json"
require "cob_az_index/macros"

extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON
extend CobAzIndex::Macros

if File.exist? "config/blacklight.yml"
  solr_config = YAML.load_file("config/blacklight.yml")[(ENV["RAILS_ENV"] || "development")]
  solr_url = ERB.new(solr_config["az_url"]).result
else
  solr_url = ENV["SOLR_AZ_URL"]
end

settings do
  provide "reader_class_name", "TrajectPlus::JsonReader"
  provide "solr_writer.commit_timeout", (15 * 60)
  provide "solr.url", solr_url
  provide "solr_writer.commit_on_close", "false"
  provide "solr_writer.max_skipped", 0

  if ENV["SOLR_AUTH_USER"] && ENV["SOLR_AUTH_PASSWORD"]
    provide "solr_writer.basic_auth_user", ENV["SOLR_AUTH_USER"]
    provide "solr_writer.basic_auth_password", ENV["SOLR_AUTH_PASSWORD"]
  end
end

each_record do |record, context|
  if record["enable_hidden"].to_s == "1"
    context.skip!("Skipping hidden database.")
  end
end

to_field "id", extract_json("$.id")

to_field "format", ->(rec, acc) {
  types = rec.fetch("az_types", [])
  types.each { |type| acc << type["name"] unless type["name"] == "Database" }
}
to_field "format_t", ->(rec, acc) {
  types = rec.fetch("az_types", [])
}
to_field "database_display", ->(rec, acc) {
  types = rec.fetch("az_types", [])
  types = types << { "name" => "Database" }
  types.each { |type| acc << type["name"] if type["name"] == "Database" }
}

to_field "title_t", extract_json("$.name")
to_field "title_sort", extract_json("$.name")
to_field "alt_names_t", extract_json("$.alt_names")
to_field "title_statement_display", extract_json("$.name")
to_field "title_truncated_display", extract_json("$.name"), &truncate(300)
to_field "az_vendor_id_display", extract_json("$.az_vendor_id")
to_field "az_vendor_name_display", extract_json("$.az_vendor_name")

to_field "note_display", extract_json("$.description")
to_field "note_t", extract_json("$.description")
to_field "availability_facet", -> (rec, acc) {
  if rec["enable_trial"].to_s == "1"
    acc << "Trial"
  end
}

to_field "electronic_resource_display", -> (rec, acc) {
  url =
    if [1, true].include? rec.dig("meta", "enable_proxy")
      "http://libproxy.temple.edu/login?url=#{rec['url']}"
    else
      rec["url"]
    end
  acc << { title: rec["name"], url: url }.to_json
}

to_field "record_update_date", extract_json("$.updated")

to_field "subject_display", -> (rec, acc) {
  rec["subjects"]&.each { |subject| acc << subject["name"] }
}

to_field "subject_facet", -> (rec, acc) {
  rec["subjects"]&.each { |subject| acc << subject["name"] }
}

to_field "subject_t", -> (rec, acc) {
  rec["subjects"]&.each { |subject| acc << subject["name"] }
}

each_record do |record, context|
  if ENV["SOLR_DISABLE_UPDATE_DATE_CHECK"] == "yes"
    context.output_hash["record_update_date"] = [ Time.zone.now.to_s ]
  end
end
