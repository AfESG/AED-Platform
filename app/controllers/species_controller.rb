class SpeciesController < ApplicationController

  def range_states
    @species = Species.find params[:species_id]
    respond_to do |format|
      format.js {
        render :json => @species.range_states, :callback => params[:callback]
      }
    end
  end

end
