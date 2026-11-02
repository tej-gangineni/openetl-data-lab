#!/usr/bin/env bash
# Download REAL public datasets into downloads/. Nothing is generated locally. Safe to re-run (skips existing files).
# Add HDFS=1 for the 186 MB HDFS log archive (a few hundred MB unpacked).
set -euo pipefail
cd "$(dirname "$0")/.."; D=downloads; UA="openetl-lab/1.0 (test data)"
get() { [ -s "$2" ] && return 0; mkdir -p "$(dirname "$2")"; echo "  $2"; curl -fsSL --retry 5 --retry-all-errors -A "$UA" -o "$2.part" "$1" && mv "$2.part" "$2"; }

echo "logs (loghub, Zenodo 8196385)"
Z=https://zenodo.org/records/8196385/files
for n in Apache SSH Linux HealthApp; do
  if [ ! -d $D/logs/$n ]; then get $Z/$n.tar.gz /tmp/lab-$n.tgz; mkdir -p $D/logs/$n; tar -xzf /tmp/lab-$n.tgz -C $D/logs/$n; rm /tmp/lab-$n.tgz; fi
done
if [ ! -d $D/logs/Hadoop ]; then get $Z/Hadoop.zip /tmp/lab-Hadoop.zip; mkdir -p $D/logs/Hadoop; unzip -q -o /tmp/lab-Hadoop.zip -d $D/logs/Hadoop; rm /tmp/lab-Hadoop.zip; fi
if [ "${HDFS:-0}" = 1 ] && [ ! -d $D/logs/HDFS ]; then get $Z/HDFS_v1.zip /tmp/lab-HDFS.zip; mkdir -p $D/logs/HDFS; unzip -q -o /tmp/lab-HDFS.zip -d $D/logs/HDFS; rm /tmp/lab-HDFS.zip; fi

echo "csv (seaborn-data on GitHub)"
S=https://raw.githubusercontent.com/mwaskom/seaborn-data/master
for n in diamonds taxis flights; do get $S/$n.csv $D/csv/$n/$n.csv; done

echo "json (JSONPlaceholder, mledoze/countries)"
for n in posts comments todos photos users albums; do get https://jsonplaceholder.typicode.com/$n $D/json/$n/$n.json; done
get https://raw.githubusercontent.com/mledoze/countries/master/countries.json $D/json/countries/countries.json

echo "books (Project Gutenberg)"
for id in 1342 2701 84 11 1661 345 98 1260; do get https://www.gutenberg.org/cache/epub/$id/pg$id.txt $D/books/pg$id.txt; done

echo "RFCs (rfc-editor.org)"
for n in 791 793 1035 2616 5246 8446 9110 9293 4271 7540; do get https://www.rfc-editor.org/rfc/rfc$n.txt $D/rfc/rfc$n.txt; done

echo "web pages (Wikipedia HTML)"
for t in Telecommunications_network 5G 4G "LTE_(telecommunication)" Cell_site Internet_protocol_suite Domain_Name_System Border_Gateway_Protocol Optical_fiber Wi-Fi Bluetooth Satellite_internet_constellation Network_function_virtualization Software-defined_networking Quality_of_service Packet_switching Radio_access_network SIM_card Roaming Mobile_phone_tracking Network_operations_center Syslog Intrusion_detection_system Apache_HTTP_Server Secure_Shell; do
  get "https://en.wikipedia.org/wiki/$t" "$D/web/$(echo "$t" | tr -c 'A-Za-z0-9\n' _).html"; sleep 0.3; done
echo; du -sh $D/*; find $D -type f | wc -l
