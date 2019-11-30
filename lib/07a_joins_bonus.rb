# == Schema Information
#
# Table name: albums
#
#  asin        :string       not null, primary key
#  title       :string
#  artist      :string
#  price       :float
#  rdate       :date
#  label       :string
#  rank        :integer
#
# Table name: styles
#
# album        :string       not null
# style        :string       not null
#
# Table name: tracks
# album        :string       not null
# disk         :integer      not null
# posn         :integer      not null
# song         :string

require_relative './sqlzoo.rb'

def alison_artist
  # Select the name of the artist who recorded the song 'Alison'.
  execute(<<-SQL)
    SELECT
      artist
    FROM
      albums
    WHERE
      asin = (
        SELECT
          album
        FROM
          tracks
        WHERE
          song = 'Alison'
      )
  SQL
end

def exodus_artist
  # Select the name of the artist who recorded the song 'Exodus'.
  execute(<<-SQL)
    SELECT
      artist
    FROM
      albums
    WHERE
      asin = (
        SELECT
          album
        FROM
          tracks
        WHERE
          song = 'Exodus'
      )
  SQL
end

def blur_songs
  # Select the `song` for each `track` on the album `Blur`.
  execute(<<-SQL)
    SELECT
      song
    FROM
      tracks
    WHERE
      album = (
        SELECT
          asin
        FROM
          albums
        WHERE
          title = 'Blur'
      )
  SQL
end

def heart_tracks
  # For each album show the title and the total number of tracks containing
  # the word 'Heart' (albums with no such tracks need not be shown). Order first by
  # the number of such tracks, then by album title.
  execute(<<-SQL)
    WITH
      hearts AS (
        SELECT
          album
        FROM
          tracks
        WHERE
          song LIKE '%Heart%'
      )
    SELECT
      title, COUNT(title) 
    FROM
      albums
    INNER JOIN
      hearts ON albums.asin = hearts.album
    GROUP BY
      title
    ORDER BY
      COUNT(title) DESC,
      title
  SQL
end

def title_tracks
  # A 'title track' has a `song` that is the same as its album's `title`. Select
  # the names of all the title tracks.
  execute(<<-SQL)
    SELECT
      song
    FROM
      tracks
    WHERE
      album = (
        SELECT
          asin
        FROM
          albums
        WHERE
          title = song
      )

  SQL
end

def eponymous_albums
  # An 'eponymous album' has a `title` that is the same as its recording
  # artist's name. Select the titles of all the eponymous albums.
  execute(<<-SQL)
    SELECT
      title
    FROM
      albums
    WHERE
      artist = title
  SQL
end

def song_title_counts
  # Select the song names that appear on more than two albums. Also select the
  # COUNT of times they show up.

  # the spec here is wrong again.... there's a bunch of songs that appear a bunch
  # including ["[Silence]", "22"] and ["[Untitled Track]", "6"]
  # so no clue what the spec is talking about extra elements here

  execute(<<-SQL)
    SELECT
      song, COUNT(song)
    FROM
      tracks
    GROUP BY 
      song
    HAVING
      COUNT(song) > 2
  SQL
end

def best_value
  # A "good value" album is one where the price per track is less than 50
  # pence. Find the good value albums - show the title, the price and the number
  # of tracks.
  execute(<<-SQL)
    WITH
      trackcount AS (
        SELECT
          album, COUNT(album) as tcount
        FROM
          tracks
        GROUP BY 
          album
      )
    SELECT
      title, price, tcount
    FROM
      albums
    INNER JOIN
      trackcount ON albums.asin = trackcount.album
    WHERE
      (price / tcount) < 0.5
  SQL
end

def top_track_counts
  # Wagner's Ring cycle has an imposing 173 tracks, Bing Crosby clocks up 101
  # tracks. List the top 10 albums. Select both the album title and the track
  # count, and order by both track count and title (descending).
  execute(<<-SQL)
    WITH
      trackcount AS (
        SELECT
          album, COUNT(album) as tcount
        FROM
          tracks
        GROUP BY 
          album
      )
    SELECT
      title, tcount
    FROM
      albums
    INNER JOIN
      trackcount ON albums.asin = trackcount.album
    ORDER BY
      tcount DESC,
      title DESC LIMIT 10
      
  SQL
end

def rock_superstars
  # Select the artist who has recorded the most rock albums, as well as the
  # number of albums. HINT: use LIKE '%Rock%' in your query.
  execute(<<-SQL)
    WITH
      blah AS (
        SELECT DISTINCT
          albums.artist AS "artist", albums.title
        FROM
          albums
        INNER JOIN
          styles ON albums.asin = styles.album
        WHERE
          style LIKE '%Rock%'
        ORDER BY
          albums.artist
      )
    SELECT
      artist, COUNT(artist)
    FROM
      blah
    GROUP BY
      artist
    ORDER BY
      COUNT(artist) DESC LIMIT 1
  SQL
end

def expensive_tastes
  # Select the five styles of music with the highest average price per track,
  # along with the price per track. One or more of each aggregate functions,
  # subqueries, and joins will be required.
  #
  # HINT: Start by getting the number of tracks per album. You can do this in a
  # subquery. Next, JOIN the styles table to this result and use aggregates to
  # determine the average price per track.
  execute(<<-SQL)
    WITH
      trackcount AS (
        SELECT
          album, COUNT(album) as tcount
        FROM
          tracks
        GROUP BY 
          album
      ),
      priceper AS (
        SELECT
          (albums.price/trackcount.tcount) AS "price", albums.asin AS "album"
        FROM
          albums
        INNER JOIN
          trackcount ON albums.asin = trackcount.album
      )
    SELECT
      style, priceper.price
    FROM
      styles
    INNER JOIN
      priceper ON styles.album = priceper.album
    WHERE 
      priceper.price > 0
    ORDER BY
      priceper.price DESC LIMIT 5
  SQL
end

# expected:
# [
#   ["Styles > Classical > Forms & Genres > Theatrical, Incidental & Program Music > Incidental Music", "2.3557142857142857"],
#   ["Styles > Classical > Historical Periods > Romantic (c.1820-1910) > Ballets & Dances", "2.3557142857142857"],
#   ["Styles > Classical > Historical Periods > Romantic (c.1820-1910) > Forms & Genres > Theatrical, Inci", "2.3557142857142857"],
#   ["Styles > Classical > Forms & Genres > Symphonies > Romantic", "1.8980000000000000"],
#   ["Styles > Classical > Symphonies > General", "1.8980000000000000"]
# ]
  
# got:
# [
#   ["Styles > Classical > Historical Periods > Classical (c.1770-1830) > General", "2.3557142857142857"],
#   ["Styles > Classical > Forms & Genres > Theatrical, Incidental & Program Music > Incidental Music", "2.3557142857142857"],
#   ["Styles > Classical > Forms & Genres > Symphonies > Romantic", "2.3557142857142857"],
#   ["Styles > Classical > General", "2.3557142857142857"],
#   ["Styles > Classical > Historical Periods > Romantic (c.1820-1910) > Ballets & Dances", "2.3557142857142857"]
# ]