# == Schema Information
#
# Table name: nobels
#
#  yr          :integer
#  subject     :string
#  winner      :string

require_relative './sqlzoo.rb'

# BONUS PROBLEM: requires sub-queries or joins. Attempt this after completing
# sections 04 and 07.

def physics_no_chemistry
  # In which years was the Physics prize awarded, but no Chemistry prize?
  execute(<<-SQL)
    WITH
      physics AS (
        SELECT
          yr
        FROM
          nobels
        WHERE
          subject = 'Physics'
      ),
      chem AS (
        SELECT
          yr
        FROM
          nobels
        WHERE
          subject = 'Chemistry'
      ),
      notchem AS (
        SELECT
          nobels.yr
        FROM
          nobels
        FULL OUTER JOIN 
          chem ON chem.yr = nobels.yr
        WHERE
          chem.yr IS NULL
      )
    SELECT DISTINCT
      physics.yr
    FROM
      notchem
    INNER JOIN
      physics ON physics.yr = notchem.yr
      
  SQL
end
