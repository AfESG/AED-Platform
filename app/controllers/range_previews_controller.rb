class RangePreviewsController < ApplicationController
  def index
    respond_to do |format|
      format.html {
        render layout: 'fullscreen'
      }
      format.json { render json: @analysis }
    end
  end

  def map
    features = []

    RangePreview.order(:id).each do |range|
      feature = RGeo::GeoJSON.encode(range.geom)
      if feature
        feature['properties'] = {
            range_id: range.id,
            range_type: range.range_type,
            original_comments: range.original_comments,
            source_year: range.source_year,
            published_year: range.published_year,
            comments: range.comments
        }
        features << feature
      end
    end

    render json: {
      type: 'FeatureCollection',
      features: features
    }
  end
end
