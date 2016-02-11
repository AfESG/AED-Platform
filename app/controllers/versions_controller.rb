class VersionsController < ApplicationController

  include ActionView::Helpers::DateHelper

  def history
    @item_type = params[:item_type].gsub(/[^\w_]/,'')

    users = {}
    User.all.each do |user|
      users[user.id] = user.email
    end

    @item = eval(@item_type).find(params[:id])
    result = []
    @item.versions.each do |version|
      changeset = version.changeset
      changeset.delete 'created_at'
      changeset.delete 'updated_at'
      result << {
        whodunnit: users[version.whodunnit.to_i],
        created_at: version.created_at,
        ago: "#{time_ago_in_words(version.created_at)} ago",
        changeset: changeset
      }
    end
    render :json => result.reverse
  end

end
