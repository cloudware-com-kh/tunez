SELECT
  s0."id",
  s0."name",
  s0."updated_at",
  s0."inserted_at",
  s0."biography",
  s0."previous_names",
  s0."user_id",
  COALESCE(s1."album_count"::bigint, $1::bigint)::bigint,
  s1."latest_album_year_released"::bigint::bigint,
  s1."cover_image_url"::text::text
FROM (
  SELECT
    sa0."id" AS "id",
    sa0."name" AS "name",
    sa0."updated_at" AS "updated_at",
    sa0."inserted_at" AS "inserted_at",
    sa0."biography" AS "biography",
    sa0."previous_names" AS "previous_names",
    sa0."user_id" AS "user_id"
  FROM "artists" AS sa0
  WHERE (sa0."name"::text ILIKE $2)
  ORDER BY sa0."updated_at" DESC, sa0."id"
  LIMIT $3
) AS s0
LEFT OUTER JOIN LATERAL (
  SELECT
    sa0."artist_id" AS "artist_id",
    COALESCE(count(*) FILTER (WHERE $4), $5::bigint)::bigint AS "album_count",
    any_value(sa0."year_released"::bigint ORDER BY sa0."year_released" DESC)
      FILTER (WHERE $6 AND NOT (sa0."year_released"::bigint IS NULL))::bigint AS "latest_album_year_released",
    any_value(sa0."cover_image_url"::text ORDER BY sa0."year_released" DESC)
      FILTER (WHERE $7 AND NOT (sa0."cover_image_url"::text IS NULL))::text AS "cover_image_url"
  FROM "public"."albums" AS sa0
  WHERE (s0."id" = sa0."artist_id")
  GROUP BY sa0."artist_id"
) AS s1 ON TRUE

-- Parameters: [0, "%%", 13, true, 0, true, true]