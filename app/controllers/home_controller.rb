class HomeController < ApplicationController
  before_action :set_suggestions
  before_action :set_feeds

  def index
  end

  private

  def set_suggestions
    @suggestions = suggest_followers(current_user)
  end

  # Lista de Adjacência pois utilizamos Hash;
  # Sugere conexões com base no peso das arestas
  def suggest_followers(user)
    users = User.all

    # Inicializa um Hash;
    user_likes = {}
    # A variável "other_user" receberá cada usuário presente no banco;
    users.each do |other_user|
      # Coletando os posts que o usuário x curtiu e adiciona ao hash;
      user_likes[other_user.id] = other_user.liked_posts.pluck(:id)
    end

    # Inicializa um Hash;
    connections = {}
    # A variável "user_x" receberá cada usuário presente no banco;
    users.each do |user_x|
      # A variável "user_y" receberá cada usuário presente no banco;
      users.each do |user_y|
        # compara se o usuário x e y são iguais evitando auto-referência
        next if user_x == user_y

        # Armazena os posts que o usuário x e o usuário y curtiram em comum;
        common_posts = user_likes[user_x.id] & user_likes[user_y.id]
        # Ignora se não há posts em comum
        next if common_posts.empty?

        # Adiciona o peso da conexão
        connections[[ user_x.id, user_y.id ]] = common_posts.size
      end
    end

    # Encontra as sugestões para o usuário atual
    # Criamos um novo Hash chamado "user_connections" que receberá um select no Hash de conexões
    user_connections = connections.select do |(source, target), weight|
      # Buscando conexões que vão do usuário atual ou para o usuário atual;
      source == user.id || target == user.id
    end

    # Ordena as sugestões por peso (maior relevância primeiro "-weight")
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
