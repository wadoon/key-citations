#!/usr/bin/bash

declare -a dois

dois=("10.1007/978-3-540-69061-0"      # first key book
      "10.1007/978-3-319-49812-6"   # second key book
      "10.1007/s10270-004-0058-x"     # tool paper 2005

      # chapters of new key book
      "10.1007/978-3-319-49812-6_1"
      "10.1007/978-3-319-49812-6_2"
      "10.1007/978-3-319-49812-6_3"
      "10.1007/978-3-319-49812-6_4"
      "10.1007/978-3-319-49812-6_5"
      "10.1007/978-3-319-49812-6_6"
      "10.1007/978-3-319-49812-6_7"
      "10.1007/978-3-319-49812-6_8"
      "10.1007/978-3-319-49812-6_9"
      "10.1007/978-3-319-49812-6_10"
      "10.1007/978-3-319-49812-6_11"
      "10.1007/978-3-319-49812-6_12"
      "10.1007/978-3-319-49812-6_13"
      "10.1007/978-3-319-49812-6_14"
      "10.1007/978-3-319-49812-6_15"
      "10.1007/978-3-319-49812-6_16"
      "10.1007/978-3-319-49812-6_17"
      "10.1007/978-3-319-49812-6_18"
      "10.1007/978-3-319-49812-6_19"

      # chapters of old key book
      "10.1007/978-3-540-69061-0_1"
      "10.1007/978-3-540-69061-0_2"
      "10.1007/978-3-540-69061-0_3"
      "10.1007/978-3-540-69061-0_4"
      "10.1007/978-3-540-69061-0_5"
      "10.1007/978-3-540-69061-0_6"
      "10.1007/978-3-540-69061-0_7"
      "10.1007/978-3-540-69061-0_8"
      "10.1007/978-3-540-69061-0_9"
      "10.1007/978-3-540-69061-0_10"
      "10.1007/978-3-540-69061-0_11"
      "10.1007/978-3-540-69061-0_12"
      "10.1007/978-3-540-69061-0_13"
      "10.1007/978-3-540-69061-0_14"
      "10.1007/978-3-540-69061-0_15"
      "10.1007/978-3-540-69061-0_16"
      "10.1007/978-3-540-69061-0_17"
     )

rm all.txt
for doi in ${dois[@]}; do
    echo "Looking up $doi in semantic scholar"
    curl -s 'https://api.semanticscholar.org/v1/paper/'${doi}'?include_unknown_references=true' \
        |  jq '.citations[].doi' -r | grep -v null >> all.txt

    echo "Looking up $doi in opencitations"
    curl -s 'https://opencitations.net/index/api/v1/citations/'$doi'?format=json' \
        | jq '.[].citing' -r | sed 's/coci => //g' >> all.txt
done

cat all.txt | sort | uniq > cleaned.txt

echo "Found $(wc -l cleaned.txt) entries"

echo "Creating URL file for cURL"
rm url.txt; touch url.txt

while read doi; do
    fn=$(echo $doi | tr "/" "_")
    echo "url = \"https://doi.org/$doi\"" >> url.txt
    echo "output = \"bibtex/$fn.bib\"" >> url.txt
done < cleaned.txt

rm -rf bibtex; mkdir bibtex
curl --parallel --parallel-immediate --parallel-max 10 \
     -L --config url.txt \
     -H 'Accept: application/x-bibtex; charset=utf-8'
