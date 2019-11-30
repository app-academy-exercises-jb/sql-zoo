# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
    WITH
      ford AS (
        SELECT
          id
        FROM
          actors
        WHERE
          name = 'Harrison Ford'
      )
    
    SELECT
      title
    FROM
      castings
    INNER JOIN 
      ford ON castings.actor_id = ford.id
    INNER JOIN
      movies ON castings.movie_id = movies.id
    ORDER BY ord
  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
    WITH
      ford AS (
        SELECT
          id
        FROM
          actors
        WHERE
          name = 'Harrison Ford'
      )
    
    SELECT
      title
    FROM
      castings
    INNER JOIN 
      ford ON castings.actor_id = ford.id
    INNER JOIN
      movies ON castings.movie_id = movies.id
    WHERE
      ord != 1
  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
    WITH
      sixtwo AS (
        SELECT
          id, title
        FROM
          movies
        WHERE
          yr = 1962
      )
    SELECT
      sixtwo.title, actors.name
    FROM
      castings
    INNER JOIN 
      sixtwo ON castings.movie_id = sixtwo.id
    INNER JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      ord = 1;
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
    WITH
      per_year AS (
        WITH
          travolta AS (
            SELECT
              id
            FROM
              actors
            WHERE
              name = 'John Travolta'
          )
        SELECT
          yr, count(title) AS "num_made"
        FROM
          castings
        INNER JOIN
          travolta ON castings.actor_id = travolta.id
        INNER JOIN
          movies ON castings.movie_id = movies.id
        GROUP BY yr
      )
    SELECT
      yr, num_made
    FROM
      per_year
    WHERE
      num_made >= 2;
      
  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
    WITH
      julie AS (
        SELECT
          id
        FROM
          actors
        WHERE
          name = 'Julie Andrews'
      ),
      julies_films AS (
        SELECT
          castings.movie_id
        FROM
          castings
        INNER JOIN
          julie ON castings.actor_id = julie.id
      ),
      films_and_stars AS (
        SELECT
          castings.movie_id, castings.actor_id
        FROM
          castings
        INNER JOIN
          julies_films ON castings.movie_id = julies_films.movie_id
        WHERE 
          ord = 1
      )
    SELECT
      title, name
    FROM
      films_and_stars
    INNER JOIN
      actors ON films_and_stars.actor_id = actors.id
    INNER JOIN
      movies ON films_and_stars.movie_id = movies.id
  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
    WITH
      succesful_actors AS (
        SELECT
          actor_id, count(actor_id) AS "num"
        FROM
          castings
        WHERE
          ord = 1
        GROUP BY
          actor_id
      )
    SELECT
      name
    FROM
      succesful_actors
    INNER JOIN
      actors ON succesful_actors.actor_id = actors.id
    WHERE
      num >= 15
    ORDER BY 
      name
  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
    SELECT
      title, count(castings.actor_id)
    FROM
      movies
    INNER JOIN
      castings ON castings.movie_id = movies.id
    INNER JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      movies.yr = 1978
    GROUP BY
      movies.title
    ORDER BY
      count(castings.actor_id) DESC,
      movies.title ASC
    
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
    WITH
      funks_movies AS (
        SELECT
          movie_id
        FROM
          castings
        INNER JOIN
          actors ON castings.actor_id = actors.id
        WHERE
          name = 'Art Garfunkel'
      )
    SELECT
      name
    FROM
      funks_movies
    INNER JOIN
      castings ON funks_movies.movie_id = castings.movie_id
    INNER JOIN 
      actors ON castings.actor_id = actors.id
    WHERE
      name != 'Art Garfunkel'
  SQL
end
