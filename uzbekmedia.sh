#!/bin/bash

# uzbekmedia.sh: Scrapes media at yande.re,konachan.com,danbooru.donmai.us

# read -p "Enter the tag: " TAG
# read -p "Enter the booru: " BOORU

HARDCODED_RATING=+-rating%3Asafe
HARDCODED_RATING_DANBOORU=+rating%3Aexplicit
HARDCODED_EXCLUDED_TAG=+-transparent_png
YANDERE_URL="https://yande.re"
KONACHAN_URL="https://konachan.com"
DANBOORU_API="https://danbooru.donmai.us/posts.json?tags="
API_QUERY="/post.json?tags="

if [ -z "$1" ] || [ -z "$2" ]; then
 # No tag and booru specified.
  echo "Usage: `basename $0` tag"
  echo "Booru options: yandere, konachan, danbooru"
  exit 1
fi

TAG=$1
BOORU=$2

# if [ -z "$TAG" ] || [ -z "$BOORU" ]; then
#  No tag and booru specified.
#   echo "A tag is required."
#   echo "A booru is required."
#   exit 1
# fi

case "$BOORU" in
  yandere)
    URL="${YANDERE_URL}${API_QUERY}${TAG}${HARDCODED_RATING}${HARDCODED_EXCLUDED_TAG}"
    DIR="yandere_$TAG"
    JQ_FILTER='.[].jpeg_url'
    ;;
  konachan)
    URL="${KONACHAN_URL}${API_QUERY}${TAG}${HARDCODED_RATING}"
    DIR="konachan_$TAG"
    JQ_FILTER='.[].jpeg_url'
    ;;
  danbooru)
    URL="${DANBOORU_API}${TAG}${HARDCODED_RATING_DANBOORU}"
    DIR="danbooru_$TAG"
    JQ_FILTER='.[].file_url'
    ;;
  *)
    echo "Invalid booru."
    echo "Valid options: yandere, konachan, danbooru"
    exit 1
    ;;
esac

# Create directory for the images
mkdir -p "$DIR"

# Download the image
curl -s "$URL" | jq -r "$JQ_FILTER" | aria2c -i- -d "$DIR"
