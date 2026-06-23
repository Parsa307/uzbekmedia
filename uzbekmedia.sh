#!/bin/bash

# uzbekmedia.sh: Scrapes media at yande.re,konachan.com,danbooru.donmai.us,rule34.xxx

# read -p "Enter the tag: " TAG
# read -p "Enter the booru: " BOORU
# read -p "Enter the limit (optional): " LIMIT

HARDCODED_RATING=+-rating%3Asafe
HARDCODED_RATING_DANBOORU=+rating%3Aexplicit
HARDCODED_EXCLUDED_TAG=+-transparent_png
YANDERE_URL="https://yande.re"
KONACHAN_URL="https://konachan.com"
DANBOORU_API="https://danbooru.donmai.us/posts.json?tags="
RULE34_API="https://api.rule34.xxx/index.php?page=dapi&s=post&q=index&json=1"
RULE34_API_KEY="1b7ac421841879b859d0a0d771b6df8e4a3419e0ce54f234e90bc0c8969ac6ada2972a757a25a606e33dfa9bbd946a0ca231f90c38644336367db73f918b61ed"
RULE34_USER_ID="5925125"
API_QUERY="/post.json?tags="

if [ -z "$1" ] || [ -z "$2" ]; then
 # No tag and booru specified.
  echo "Usage: `basename $0` tag"
  echo "Booru options: yandere, konachan, danbooru, rule34"
  exit 1
fi

TAG=$1
BOORU=$2
LIMIT=$3

TAGS=$(echo "$TAG" | tr '+' '_')

# if [ -z "$TAG" ] || [ -z "$BOORU" ]; then
#  No tag and booru specified.
#   echo "A tag is required."
#   echo "A booru is required."
#   exit 1
# fi

case "$BOORU" in
  yandere)
    URL="${YANDERE_URL}${API_QUERY}${TAG}${HARDCODED_RATING}${HARDCODED_EXCLUDED_TAG}"
    DIR="yandere_$TAGS"
    JQ_FILTER='.[].jpeg_url'
    ;;
  konachan)
    URL="${KONACHAN_URL}${API_QUERY}${TAG}${HARDCODED_RATING}"
    DIR="konachan_$TAGS"
    JQ_FILTER='.[].jpeg_url'
    ;;
  danbooru)
    URL="${DANBOORU_API}${TAG}${HARDCODED_RATING_DANBOORU}"
    DIR="danbooru_$TAGS"
    JQ_FILTER='.[].file_url'
    ;;
  rule34)
    URL="${RULE34_API}&tags=${TAG}&api_key=${RULE34_API_KEY}&user_id=${RULE34_USER_ID}"
    DIR="rule34_$TAGS"
    JQ_FILTER='.[].file_url'
    ;;
  *)
    echo "Invalid booru."
    echo "Valid options: yandere, konachan, danbooru, rule34"
    exit 1
    ;;
esac

# Pass limit parameter if provided
if [ -n "$LIMIT" ]; then
  URL="${URL}&limit=${LIMIT}"
fi

# Create directory for the images
mkdir -p "$DIR"

# Download medias
curl -s "$URL" | jq -r "$JQ_FILTER" | aria2c -c -i- -d "$DIR"
