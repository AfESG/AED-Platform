class RangePreviewsController < ApplicationController

  before_filter :authenticate_superuser!

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
            status: range.status,
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

  # PATCH /range_previews/1.json
  def update
    @range_preview = RangePreview.find(params[:id])
    if params[:range_preview] and params[:range_preview][:comments] != nil and params[:range_preview][:comments].blank?
      params[:range_preview][:comments] = nil
    end

    respond_to do |format|
      if @range_preview.update_attributes(params[:range_preview])
        format.json { head :no_content }
      else
        format.json { render json: @range_preview.errors, status: :unprocessable_entity }
      end
    end
  end

end
