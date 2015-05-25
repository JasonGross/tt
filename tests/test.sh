#!/bin/bash

BASEDIR=`dirname "$0"`
DIFF=`which diff`

if [ ! -x "$DIFF" ]
then
    echo "Cannot find the diff command. Exiting."
    exit 1
fi

if [ -x "$BASEDIR/../andromeda" ]
then
  ANDROMEDA="$BASEDIR/../andromeda"
elif [ -x "$BASEDIR/../andromeda.native" ]
then
  ANDROMEDA="$BASEDIR/../andromeda.byte"
elif [ -x "$BASEDIR/../andromeda.byte" ]
then
  ANDROMEDA="$BASEDIR/../andromeda.byte"
else
  echo "Cannot find the Andromeda executable. Compile Andromeda first."
  exit 1
fi

VALIDATE=0
if [ "$1" = "-v" ]
then
    VALIDATE=1
fi

RET=0

for FILE in "$BASEDIR"/*.m31
  do
  "$ANDROMEDA" "$FILE" >"$FILE.out" 2>&1
  if [ -f "$FILE.ref" ]
      then
      RESULT=`"$DIFF" "$FILE.out" "$FILE.ref"`
      if [ "$?" = "0" ]
      then
      echo "Passed:  $FILE"
      rm "$FILE.out"
      else
      echo "FAILED:  $FILE"
      if [ $VALIDATE = "1" ]
          then
          "$DIFF" "$FILE.out" "$FILE.ref"
          read -p "Validate $FILE.out as new $FILE.ref? (y/n) [n] " ans
          if [ "$ans" = "y" -o "$ans" = "Y" ]
          then
          mv "$FILE.out" "$FILE.ref"
          echo "Validated: $FILE"
          else
          RET=1
          fi
      else
          RET=1
      fi
      fi

  else
      mv "$FILE.out" "$FILE.ref"
      echo "Created: $FILE.ref"
  fi
done

exit $RET
