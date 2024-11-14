class GraphController < ApplicationController
  def show
  end

  def graph_data
    users = User.all

    nodes = users.map do |user|
      { id: user.id, name: user.full_name }
    end

    links = Follow.where(accepted: true).map do |follow|
      {
        source: follow.follower_id,
        target: follow.followed_id,
        bidirectional: follow.followed.followings.include?(follow.follower)
      }
    end

    render json: { nodes: nodes, links: links }
  end
end
