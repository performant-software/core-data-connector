require_relative '../typesense/helper'
require_relative '../typesense/options'

namespace :typesense do
  desc 'Creates a new Typesense collection'
  task create: :environment do
    options = Typesense::Options.parse(ARGV) do |opts|
      opts.banner = 'Usage: typesense:create -- --host --port --protocol --api-key --collection-name'
    end

    helper = Typesense::Helper.new(
      host: options[:host],
      port: options[:port],
      protocol: options[:protocol],
      api_key: options[:api_key],
      collection_name: options[:collection_name]
    )

    helper.create
  end

  desc 'Deletes the Typesense collection'
  task delete: :environment do
    options = Typesense::Options.parse(ARGV) do |opts|
      opts.banner = 'Usage: typesense:delete -- --host --port --protocol --api-key --collection-name'
    end

    helper = Typesense::Helper.new(
      host: options[:host],
      port: options[:port],
      protocol: options[:protocol],
      api_key: options[:api_key],
      collection_name: options[:collection_name]
    )

    begin
      helper.delete
    rescue
      # Do nothing, collection doesn't exist yet
    end
  end

  desc 'Index documents into Typesense'
  task index: :environment do
    options = Typesense::Options.parse(ARGV) do |opts, options|
      opts.banner = 'Usage: typesense:index -- --host --port --protocol --api-key --collection-name --project-models'
      opts.on('-m', '--project-models ARG', Array) { |ids| options[:project_model_ids] = ids.map(&:to_i) }
    end

    helper = Typesense::Helper.new(
      host: options[:host],
      port: options[:port],
      protocol: options[:protocol],
      api_key: options[:api_key],
      collection_name: options[:collection_name]
    )

    helper.index options[:project_model_ids]
  end
end