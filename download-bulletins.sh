#!/bin/sh

# useage: sh download-bulletins.sh

# check for dependencies
if ! hash pdfgrep 2>/dev/null; then
  echo "pdfgrep must be installed."
  exit 2
fi

if ! hash wget 2>/dev/null; then
  echo "wget must be installed."
  exit 2
fi

# download documents
mkdir -p ../raw-downloads

for MONTH in {01..12}
do

  for YEAR in {00..99}
  do
  CODE=$(printf "%02d%02d\n" $MONTH $YEAR)
  if [[ -f "../raw-downloads/ieee_${CODE}.pdf" ]]; then
    echo "ieee_${CODE}.pdf already exists!"
  else
    wget https://www.ewh.ieee.org/r2/pittsburgh/bulletins/ieee_${CODE}.pdf --output-document=../raw-downloads/ieee_${CODE}.pdf
  fi
  done

done

# delete empty documents
find ../raw-downloads/ -empty -type f -delete

# rename documents
mkdir -p ../formatted-downloads

# PDF pattern for the title, works for most files
pat="([a-zA-Z]+)( [0-9]+)?([ ]?/?[ ]?|[ ]+)Volume ([0-9]+), No. ([0-9]+)"

for MONTH in {01..12}
do

  for YEAR in {00..99}
  do
  CODE=$(printf "%02d%02d\n" $MONTH $YEAR)
  FILE="../raw-downloads/ieee_${CODE}.pdf"

  if [[ -f $FILE ]]; then

      s=$(pdfgrep -o -P -e "${pat}" ${FILE})
      [[ $s =~ $pat ]]

      if [ -z "${BASH_REMATCH[0]}" ]; then
          echo "$FILE didn't match."
      else
        NEW_FILE_NAME="../formatted-downloads/Volume ${BASH_REMATCH[4]}, No. $(printf "%02d" ${BASH_REMATCH[5]}) (${BASH_REMATCH[1]} $(printf "%04d" ${BASH_REMATCH[2]})).pdf"
        if [[ -f $NEW_FILE_NAME ]]; then
          echo "$NEW_FILE_NAME already exists!"
        else
          cp "${FILE}" "${NEW_FILE_NAME}"
        fi
      fi
  fi

  done

done
