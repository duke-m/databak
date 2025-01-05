-- Description: Re-Create all roles, including superuser and "groups" without passwords.
-- no reserved pg_ roles are created
SELECT 'CREATE ROLE ' || rolname || ';'
FROM pg_catalog.pg_roles
WHERE rolname not like 'pg_%' AND rolname != 'postgres';