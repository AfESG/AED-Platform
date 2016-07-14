module CachesMap
  extend ActiveSupport::Concern

  included do
    caches_action :geojson_map,
                  expires: 24.hours,
                  cache_path: Proc.new { |c| c.params.reject { |k, _| k != 'simplify' } }
  end
end
