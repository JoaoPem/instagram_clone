class HomeController < ApplicationController
  before_action :set_suggestions
  before_action :set_feeds

  def index
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

  private

  def set_suggestions
    @suggestions = suggest_followers(current_user)
  end

  # Sugere seguidores com base na matriz de adjacência
  def suggest_followers(user)
    # Obtemos todos os usuários e a matriz de adjacência
    users = User.all
    matrix = User.adjacency_matrix

    # Encontramos o índice do usuário atual na lista de usuários
    user_index = users.index(user)
    return [] unless user_index # Retorna vazio se o usuário não estiver na lista

    # Obtemos os usuários que o usuário atual já segue (conexões de primeiro grau)
    first_degree_connections = []
    matrix[user_index].each_with_index do |connection, index|
      first_degree_connections << users[index] if connection == 1
    end

    # Conexões de segundo grau: quem os seguidores de primeiro grau estão seguindo
    second_degree_connections = []
    first_degree_connections.each do |first_degree_user|
      first_degree_index = users.index(first_degree_user)
      matrix[first_degree_index].each_with_index do |connection, index|
        second_degree_connections << users[index] if connection == 1
      end
    end

    # Remove duplicados e exclui o próprio usuário e as conexões de primeiro grau
    suggestions = (second_degree_connections - first_degree_connections - [ user ]).uniq

    # Retorna até 5 sugestões
    suggestions.sample(5)
  end

  def set_feeds
    @feeds = Post.where(user: [ current_user, current_user.followings ].flatten).order(created_at: :desc)
  end




  # IDEIA 1
  # def set_suggestions
  #   @suggestions = [current_user.followers]
  #   [current_user.followers, current_user.followings].flatten.uniq.each do |f|
  #     @suggestions.append([f.followers, f.followings])
  #   end
  #   @suggestions = [@suggestions, User.all.sample(10)].flatten.uniq - [current_user.followings, current_user].flatten
  #   @suggestions = @suggestions.sample(5)
  # end


  # IDEIA 2
  # def set_suggestions

  #   @suggestions = current_user.followers.flat_map do |follower|
  #     follower.followers + follower.followings
  #   end

  #   @suggestions = @suggestions.uniq - current_user.followings - [current_user]

  #   @suggestions = @suggestions.sample(5)

  # end
end
