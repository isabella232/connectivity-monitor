#!/bin/sh

# SPDX-FileCopyrightText: 2021 SAP SE or an SAP affiliate company and Gardener contributors
#
# SPDX-License-Identifier: Apache-2.0

cd "$(dirname "$(realpath "$0")")/.." || exit 1

curl -s "localhost:3000/api/search?type=dash-db" \
| jq -r '.[]
         | [ .uid,
            (.title              | ascii_downcase | gsub(" "; "-")),
            (.folderTitle // "." | ascii_downcase | gsub(" "; "-"))]
         | join(" ")' \
| while read -r uid new_uid folder; do
    echo "Exporting dashboard with uid '$uid' (new uid: '$new_uid') in folder '$folder'"
    mkdir -p var/lib/grafana/dashboards/"$folder"
    curl -s "http://localhost:3000/api/dashboards/uid/$uid" \
    | jq ".dashboard
          | .uid = \"$new_uid\"
          | del(.id, .iteration, .version)"                 \
    > var/lib/grafana/dashboards/"$folder/$new_uid".json
  done
