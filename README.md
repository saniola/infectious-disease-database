# Infectious Disease Database

A MySQL database normalization and analysis project built on a global infectious disease case dataset (yaws, polio, Guinea worm, rabies, malaria, HIV, tuberculosis, smallpox, and cholera).

## Contents (`schema_and_queries.sql`)

1. Creates the `pandemic` database.
2. Normalizes a flat `infectious_cases` source table into three related tables: `countries`, `diseases`, and `cases` (with foreign keys), migrating the data accordingly.
3. Aggregate queries (average/min/max/sum case counts) comparing the denormalized and normalized schemas.
4. Date arithmetic queries computing the number of years between a recorded year and the current date.
5. A reusable SQL `year_difference` function encapsulating that date calculation.

Query result screenshots are included as PNG files for each step.

## Stack

- MySQL

## Usage

Run `schema_and_queries.sql` against a MySQL server with the source `infectious_cases` table already loaded.
