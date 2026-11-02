#!/usr/bin/env python3
"""Write one OpenETL job (TOML) per target table/collection into pipelines/."""
from pathlib import Path
LAB = Path(__file__).resolve().parent.parent
PG = dict(type="postgres", dsn="postgresql://lab:lab@127.0.0.1:5433/openetl")
CH = dict(type="clickhouse", host="127.0.0.1", port=8123, database="openetl", username="lab", password="lab")
MG = dict(type="mongodb", uri="mongodb://127.0.0.1:27017", database="openetl")
ES = dict(type="elasticsearch", url="http://127.0.0.1:9200")
QD = dict(type="qdrant", url="http://127.0.0.1:6333", vector_size=384)

# (job number, target table/collection, db sink, source dir under downloads/, glob, what it is)
JOBS = [
 ("pg_apache_logs",   PG, "table", "logs-parts/Apache",   "*.log",  "Apache web-server error log (loghub)"),
 ("pg_ssh_logs",      PG, "table", "logs-parts/SSH",      "*.log",  "OpenSSH server auth log (loghub)"),
 ("pg_books",         PG, "table", "books",         "*.txt",  "Project Gutenberg novels"),
 ("ch_linux_logs",    CH, "table", "logs-parts/Linux",    "*.log",  "Linux syslog (loghub)"),
 ("ch_diamonds",      CH, "table", "csv/diamonds",  "*.csv",  "diamonds price table, 54k rows"),
 ("ch_taxis",         CH, "table", "csv/taxis",     "*.csv",  "NYC taxi trips"),
 ("ch_flights",       CH, "table", "csv/flights",   "*.csv",  "monthly airline passengers"),
 ("mongo_posts",      MG, "collection", "json-items/posts",     "*.json", "JSONPlaceholder posts"),
 ("mongo_comments",   MG, "collection", "json-items/comments",  "*.json", "JSONPlaceholder comments"),
 ("mongo_todos",      MG, "collection", "json-items/todos",     "*.json", "JSONPlaceholder todos"),
 ("mongo_users",      MG, "collection", "json-items/users",     "*.json", "JSONPlaceholder users"),
 ("mongo_albums",     MG, "collection", "json-items/albums",    "*.json", "JSONPlaceholder albums"),
 ("mongo_photos",     MG, "collection", "json-items/photos",    "*.json", "JSONPlaceholder photos"),
 ("mongo_countries",  MG, "collection", "json-items/countries", "*.json", "countries of the world"),
 ("es_wiki_pages",    ES, "index", "web",           "*.html", "Wikipedia HTML pages"),
 ("es_healthapp_logs",ES, "index", "logs-parts/HealthApp","*.log",  "HealthApp mobile app log (loghub)"),
 ("es_hadoop_logs",   ES, "index", "logs/Hadoop",   "*.log",  "Hadoop container logs (loghub)"),
 ("qdrant_rfcs",      QD, "collection", "rfc",      "*.txt",  "IETF RFC documents"),
]
out = LAB / "pipelines"; out.mkdir(exist_ok=True)
for old in out.glob("*.toml"): old.unlink()
for name, sink, key, src, glob, desc in JOBS:
    kind = name.split("_", 1)[0]; target = name.split("_", 1)[1]
    s = {k: v for k, v in sink.items()}
    body = "".join(f'{k:<11}= {v!r}\n'.replace("'", '"') if isinstance(v, str) else f'{k:<11}= {v}\n' for k, v in s.items() if k != "type")
    (out / f"{name}.toml").write_text(f'''name        = "{name}"
description = "{desc} -> {sink["type"]} {key} {target}"

[[sources]]
id        = "files"
type      = "local"
mode      = "full_refresh"
path      = "{LAB}/downloads/{src}"
filter    = "{glob}"
recursive = true

[[transforms]]
type     = "extract"
strategy = "fast"
entities = false

[[sinks]]
id         = "out"
type       = "{sink["type"]}"
write_mode = "append"
{key:<10} = "{target}"
{body}''')
print(len(JOBS), "pipelines written")
