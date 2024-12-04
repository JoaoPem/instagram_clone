class GraphController < ApplicationController
  def show
  end

  def graph_data
    users = User.all

    # Define os nós (usuários)
    nodes = users.map do |user|
      {
        id: user.id,
        name: user.full_name,
        isCurrentUser: user == current_user  # Identifica o current_user
      }
    end

    # Calcula as arestas com base nos posts curtidos em comum
    links = []
    user_likes = {}

    # Mapeia os posts curtidos por cada usuário
    users.each do |user|
      user_likes[user.id] = user.liked_posts.pluck(:id) # Obtém IDs dos posts curtidos
    end

    # Compara todos os pares de usuários para encontrar posts em comum
    users.to_a.combination(2).each do |user_x, user_y|
      common_posts = user_likes[user_x.id] & user_likes[user_y.id] # Interseção dos posts curtidos

      next if common_posts.empty? # Ignora se não há posts em comum

      # Adiciona uma aresta com o peso correspondente ao número de posts curtidos em comum
      links << {
        source: user_x.id,
        target: user_y.id,
        weight: common_posts.size # Número de posts curtidos em comum
      }
    end

    render json: { nodes: nodes, links: links }
  end
end
