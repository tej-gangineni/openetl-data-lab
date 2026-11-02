#!/usr/bin/env bash
# Empty every target so a reload never duplicates rows (drops all tables/collections/indices the lab created).
docker exec openetl-lab-postgres psql -q -U lab -d openetl -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" >/dev/null
docker exec openetl-lab-mongodb mongosh --quiet --eval 'db.getSiblingDB("openetl").dropDatabase()' >/dev/null
for t in $(docker exec openetl-lab-clickhouse clickhouse-client --user lab --password lab -q "SELECT name FROM system.tables WHERE database='openetl'"); do
  docker exec openetl-lab-clickhouse clickhouse-client --user lab --password lab -q "DROP TABLE openetl.\`$t\`"; done
for i in $(curl -s 'http://127.0.0.1:9200/_cat/indices?h=index' | grep -v '^\.'); do curl -s -X DELETE "http://127.0.0.1:9200/$i" >/dev/null; done
for c in $(curl -s http://127.0.0.1:6333/collections | python3 -c 'import sys,json;print(*[c["name"] for c in json.load(sys.stdin)["result"]["collections"]])'); do
  curl -s -X DELETE "http://127.0.0.1:6333/collections/$c" >/dev/null; done
echo "targets emptied"
