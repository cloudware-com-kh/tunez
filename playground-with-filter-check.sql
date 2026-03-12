UPDATE "albums" AS a0
SET
  "updated_at" = (
    CASE
      WHEN (
        (
          NOT (a0."cover_image_url"::text IS NULL)
          OR ($1::bigint != a0."year_released"::bigint)
        )
        OR ($2::text != a0."name"::text)
        OR ($3::uuid != a0."updated_by_id"::uuid)
      )
      THEN $4::timestamp
      ELSE a0."updated_at"::timestamp
    END
  ),
  "cover_image_url" = NULL::text,
  "year_released" = $5::bigint,
  "name" = $6::text,
  "updated_by_id" = $7
WHERE
  (a0."id"::uuid = $8::uuid)
  AND (
    (
      CASE
        WHEN a0."created_by_id"::uuid = $9::uuid
        THEN $10
        ELSE ash_raise_error($11::jsonb)
      END
    )
  )
RETURNING
  a0."id",
  a0."name",
  a0."year_released",
  a0."cover_image_url",
  a0."inserted_at",
  a0."updated_at",
  a0."artist_id",
  a0."created_by_id",
  a0."updated_by_id";