class GraphController < ApplicationController
  def show
  end

  def graph_data
    users = User.all

    # Define os nós (usuários)
    nodes = users.map do |user|
      { id: user.id, name: user.full_name }
    end

    # Define as arestas (conexões)
    links = Follow.where(accepted: true).map do |follow|
      # Calcula os seguidores em comum (peso da aresta)
      source_user = follow.follower
      target_user = follow.followed
      common_followers_count = (source_user.followers & target_user.followers).size

      {
        source: source_user.id,
        target: target_user.id,
        bidirectional: target_user.followings.include?(source_user),
        weight: common_followers_count
      }
    end

    render json: { nodes: nodes, links: links }
  end
end
