#!/bin/bash

# uzbekmedia.sh: Scrapes media at yande.re,konachan.com,danbooru.donmai.us,safebooru.org,waifu.im,rule34.xxx

# read -p "Enter the tag: " TAG
# read -p "Enter the booru: " BOORU
# read -p "Enter the limit (optional): " LIMIT

HARDCODED_RATING=+-rating%3Asafe
HARDCODED_RATING_DANBOORU=+rating%3Aexplicit
HARDCODED_EXCLUDED_TAG=+-transparent_png
HARDCODED_RULE34_EXCLUDED_TAG=+-ai_generated
YANDERE_API="https://yande.re/post.json?tags="
KONACHAN_API="https://konachan.com/post.json?tags="
DANBOORU_API="https://danbooru.donmai.us/posts.json?tags="
SAFEBOORU_API="https://safebooru.org/index.php?page=dapi&s=post&q=index&json=1&tags="
WAIFUIM_API="https://api.waifu.im/images?IsNsfw=True"
RULE34_API="https://api.rule34.xxx/index.php?page=dapi&s=post&q=index&json=1&tags="
RULE34_API_KEY="1b7ac421841879b859d0a0d771b6df8e4a3419e0ce54f234e90bc0c8969ac6ada2972a757a25a606e33dfa9bbd946a0ca231f90c38644336367db73f918b61ed"
RULE34_USER_ID="5925125"

if [ -z "$1" ] || [ -z "$2" ]; then
 # No tag and booru specified.
  echo "Usage: `basename $0` tag"
  echo "Booru options: yandere, konachan, danbooru, waifuim, rule34"
  exit 1
fi

TAG=$1
BOORU=$2
LIMIT=$3

# if [ -z "$TAG" ] || [ -z "$BOORU" ]; then
#  No tag and booru specified.
#   echo "A tag is required."
#   echo "A booru is required."
#   exit 1
# fi

case "$BOORU" in
  yandere)
    URL="${YANDERE_API}${TAG}${HARDCODED_RATING}${HARDCODED_EXCLUDED_TAG}"
    DIR="yandere"
    JQ_FILTER='.[].jpeg_url'
    ;;
  konachan)
    URL="${KONACHAN_API}${TAG}${HARDCODED_RATING}"
    DIR="konachan"
    JQ_FILTER='.[].jpeg_url'
    ;;
  danbooru)
    URL="${DANBOORU_API}${TAG}${HARDCODED_RATING_DANBOORU}"
    DIR="danbooru"
    JQ_FILTER='.[].file_url'
    ;;
  safebooru)
    URL="${SAFEBOORU_API}${TAG}"
    DIR="safebooru"
    JQ_FILTER='.[].file_url'
    ;;
  waifuim)
    URL="${WAIFUIM_API}"
    IFS='+' read -ra TAG_ARR <<< "$TAG"
    for tag in "${TAG_ARR[@]}"; do
      URL="${URL}&IncludedTags=${tag}"
    done
    DIR="waifuim"
    JQ_FILTER='.items[].url'
    ;;
  rule34)
    URL="${RULE34_API}${TAG}${HARDCODED_RULE34_EXCLUDED_TAG}&api_key=${RULE34_API_KEY}&user_id=${RULE34_USER_ID}"
    DIR="rule34"
    JQ_FILTER='.[].file_url'
    ;;
  *)
    echo "Invalid booru."
    echo "Valid options: yandere, konachan, danbooru, waifuim, rule34"
    exit 1
    ;;
esac

# Pass limit parameter if provided
if [ -n "$LIMIT" ]; then
  if [ "$BOORU" = "waifuim" ]; then
    URL="${URL}&PageSize=${LIMIT}"
  else
    URL="${URL}&limit=${LIMIT}"
  fi
fi

mkdir -p "$DIR"

# Download medias
curl -s "$URL" | jq -r "$JQ_FILTER" | aria2c -c -i- -d "$DIR"
