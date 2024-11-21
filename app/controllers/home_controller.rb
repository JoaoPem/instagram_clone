class HomeController < ApplicationController
  before_action :set_suggestions
  before_action :set_feeds

  def index
  end

  private

  def set_suggestions
    @suggestions = suggest_followers(current_user)
  end

  # Sugere seguidores com base na matriz de adjacência de forma recursiva
  def suggest_followers(user)
    # Obtemos todos os usuários e a matriz de adjacência
    users = User.all
    matrix = User.adjacency_matrix

    # Encontramos o índice do usuário atual na lista de usuários
    user_index = users.index(user)
    return [] unless user_index # Retorna vazio se o usuário não estiver na lista

    # Usuários que o current_user já segue
    following_users = user.followings.to_set

    # Inicia o processo recursivo para encontrar conexões
    visited = Set.new([ user ]) # Para rastrear os usuários já visitados
    suggestions = Set.new     # Para acumular as sugestões

    # Explora as conexões recursivamente sem limite explícito
    explore_connections(user_index, matrix, users, visited, suggestions)

    # Filtragem final:
    # Remove o próprio usuário e os que já são seguidos
    filtered_suggestions = suggestions - following_users - [ user ]

    # Retorna até 5 sugestões aleatórias
    filtered_suggestions.to_a.sample(5)
  end

  # Método recursivo para explorar conexões de múltiplos graus
  def explore_connections(current_index, matrix, users, visited, suggestions)
    # Verifica conexões para o índice atual
    matrix[current_index].each_with_index do |connection, index|
      next if connection == 0 || visited.include?(users[index]) # Ignorar conexões inexistentes ou já visitadas

      visited.add(users[index])      # Marca o usuário como visitado
      suggestions.add(users[index])  # Adiciona às sugestões

      # Chama recursivamente para explorar o próximo nível de conexões
      explore_connections(index, matrix, users, visited, suggestions)
    end
  end

  def set_feeds
    @feeds = Post.where(user: [ current_user, current_user.followings ].flatten).order(created_at: :desc)
  end
end
