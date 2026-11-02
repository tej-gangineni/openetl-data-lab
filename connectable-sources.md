# Sources we can connect to

What the console's **Test connection** (openetl#967, PR #965) can really check, and what we have locally to point it at.
Source: `src/openetl/sources/connection_check.py` on branch `fix/963-relata-queue-mode` (probe tables `JOB_PROBES`, `STREAM_PROBES`).

## Real connection check exists

| Source type | What the test checks | Do we have something to test against? |
|---|---|---|
| `local` | path exists and is readable | **Yes**: `downloads/` in this folder (books, csv, json, logs, rfc, web) |
| `http`, `https`, `rss`, `atom`, `website`, `webcrawl` | GET status line only (body not read) | **Yes**: `scripts/serve_sources.sh start` serves `http://127.0.0.1:8765` (`/index.html`, `/feed.xml`, `/pages/*.html`) |
| `sftp` | TCP + SSH banner (login not checked) | No SFTP service running |
| `imap`, `imaps`, `email` | TCP/TLS + greeting (login not checked) | No mail server running |
| `kafka` | a broker accepts TCP | No Kafka running |
| `minio` (job and stream), `g42_obs`, `cloudian` (stream) | endpoint reachable, only when `endpoint_url` is set | No MinIO running |

## The 4 lab sources that pass today

Checked against the master's `POST /api/v1/sources/test` (read-only), all `ok: true, level: tested`:

| Name | Type | Point it at |
|---|---|---|
| lab-folder | `local` | `.../openetl-data-lab/downloads/books` |
| lab-page | `http` | `http://127.0.0.1:8765/pages/4G.html` |
| lab-feed | `rss` | `http://127.0.0.1:8765/feed.xml` |
| lab-site | `website` | `http://127.0.0.1:8765/index.html` |

Start the web server first: `scripts/serve_sources.sh start` (stop: `stop`, state: `status`). Two negative checks also behave: a missing folder and a 404 URL both come back `ok: false`.
These four were only tested, not yet added to the console or run as jobs.

## Config and capability check only ("not fully tested")

Stream listeners (`syslog`, `syslog_tcp`, `raw_tcp`, `raw_udp`, `raw_http`, `splunk_hec`, `splunk_s2s`, `splunk_tcp`) and every other registered type (for example `s3`, `gcs`, `jira`, `notion`, `slack`, `telegram`): the test only checks that required settings are present and the type can run in that role. It needs credentials or an outside service for a real check.

## Cannot run as a job today

`postgres-cdc`, `mysql-cdc`, `bigquery`, `dynamodb`, `redshift`, `snowflake` (capability failure; see openetl#966 for Postgres CDC). The databases in this lab (Postgres, ClickHouse, MongoDB, Elasticsearch, Qdrant) are sinks only; no plain reader exists yet.

## Not verified

- This list comes from reading the code and the agent's report; I have not run Test connection against every type.
- Nothing here starts containers or downloads anything.
