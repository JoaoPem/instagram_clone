class HomeController < ApplicationController
  before_action :set_suggestions
  before_action :set_feeds

  def index
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

    # Conexões de primeiro grau
    first_degree_connections = []
    matrix[user_index].each_with_index do |connection, index|
      first_degree_connections << users[index] if connection == 1
    end

    # Conexões de segundo grau
    second_degree_connections = []
    first_degree_connections.each do |first_degree_user|
      first_degree_index = users.index(first_degree_user)
      matrix[first_degree_index].each_with_index do |connection, index|
        second_degree_connections << users[index] if connection == 1
      end
    end

    # Conexões de terceiro grau
    third_degree_connections = []
    second_degree_connections.each do |second_degree_user|
      second_degree_index = users.index(second_degree_user)
      matrix[second_degree_index].each_with_index do |connection, index|
        third_degree_connections << users[index] if connection == 1
      end
    end

    # Filtragem:
    # Remove duplicados, o próprio usuário, e conexões de primeiro grau
    # Mantém conexões de segundo e terceiro grau
    suggestions = (second_degree_connections + third_degree_connections)
                  .uniq - first_degree_connections - [ user ]

    # Retorna até 5 sugestões
    suggestions.sample(5)
  end


  def set_feeds
    @feeds = Post.where(user: [ current_user, current_user.followings ].flatten).order(created_at: :desc)
  end
end
