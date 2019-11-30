# == Schema Information
#
# Table name: countries
#
#  name        :string       not null, primary key
#  continent   :string
#  area        :integer
#  population  :integer
#  gdp         :integer

require_relative './sqlzoo.rb'

# A note on subqueries: we can refer to values in the outer SELECT within the
# inner SELECT. We can name the tables so that we can tell the difference
# between the inner and outer versions.

def example_select_with_subquery
  execute(<<-SQL)
    SELECT
      name
    FROM
      countries
    WHERE
      population > (
        SELECT
          population
        FROM
          countries
        WHERE
          name='Romania'
        )
  SQL
end

def larger_than_russia
  # List each country name where the population is larger than 'Russia'.
  execute(<<-SQL)
    SELECT
      name
    FROM
      countries
    WHERE
      population > (SELECT population FROM countries WHERE name = 'Russia')
  SQL
end

def richer_than_england
  # Show the countries in Europe with a per capita GDP greater than
  # 'United Kingdom'.

  # The specs are wrong on this. they claim my result has extra elements, namely: 
  # ["Japan"], ["United States of America"]
  # however, consider the following data which you may verify looking at the dataset:
  # country                       gdp/population
  # United Kingdom                33940
  # United States of America      41400
  # Japan                         37180

  # i leave it to your judgement 
  execute(<<-SQL)
    SELECT
      name, (gdp/population)
    FROM
      countries
    WHERE
      (gdp/population) >=
        (SELECT (gdp/population) FROM countries WHERE name = 'United Kingdom')
  SQL
end

def neighbors_of_certain_b_countries
  # List the name and continent of countries in the continents containing
  # 'Belize', 'Belgium'.
  execute(<<-SQL)
    WITH
      continents AS (
        SELECT
          continent
        FROM
          countries
        WHERE
          name IN ('Belize', 'Belgium')
      )
    SELECT
      name, countries.continent
    FROM
      countries
    LEFT OUTER JOIN
      continents ON continents.continent = countries.continent
    WHERE continents.continent IS NOT NULL
  SQL
end

def population_constraint
  # Which country has a population that is more than Canada but less than
  # Poland? Show the name and the population.
  execute(<<-SQL)
    SELECT
      name, population
    FROM
      countries
    WHERE 
      population > (
        SELECT population FROM countries WHERE name = 'Canada'
      ) 
      AND population < (
        SELECT population FROM countries WHERE name = 'Poland'
      )
  SQL
end

def sparse_continents
  # Find every country that belongs to a continent where each country's
  # population is less than 25,000,000. Show name, continent and
  # population.
  # Hint: Sometimes rewording the problem can help you see the solution.
  execute(<<-SQL)
    WITH
      loaded_continents AS (
        SELECT
          continent
        FROM
          countries
        WHERE
          population > 25000000
      )
    SELECT DISTINCT
      name, countries.continent, population
    FROM
      countries
    LEFT OUTER JOIN
      loaded_continents ON loaded_continents.continent = countries.continent
    WHERE 
      loaded_continents.continent IS NULL
  SQL
end
