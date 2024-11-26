class HomeController < ApplicationController
  before_action :set_suggestions
  before_action :set_feeds

  def index
  end

  private

  def set_suggestions
    @suggestions = suggest_followers(current_user)
  end

  # Sugere conexões com base no peso das arestas
  def suggest_followers(user)
    users = User.all

    # Mapeia os posts curtidos por cada usuário
    user_likes = {}
    users.each do |other_user|
      user_likes[other_user.id] = other_user.liked_posts.pluck(:id)
    end

    # Calcula as conexões (arestas) com pesos
    connections = {}
    users.each do |user_x|
      users.each do |user_y|
        next if user_x == user_y # Evita auto-referência

        # Calcula a interseção de posts curtidos
        common_posts = user_likes[user_x.id] & user_likes[user_y.id]
        next if common_posts.empty? # Ignora se não há posts em comum

        # Adiciona o peso da conexão
        connections[[ user_x.id, user_y.id ]] = common_posts.size
      end
    end

    # Encontra as sugestões para o usuário atual
    user_connections = connections.select do |(source, target), weight|
      source == user.id || target == user.id
    end

    # Ordena as sugestões por peso (maior relevância primeiro)
    sorted_suggestions = user_connections.sort_by { |_, weight| -weight }

    # Extrai os IDs dos usuários sugeridos
    suggested_user_ids = sorted_suggestions.map do |(source, target), _|
      source == user.id ? target : source
    end

    # Retorna os usuários sugeridos
    User.where(id: suggested_user_ids)
  end

  def set_feeds
    @feeds = Post.where(user: [ current_user, current_user.followings ].flatten).order(created_at: :desc)
  end
end
