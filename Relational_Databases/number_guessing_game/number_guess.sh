#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"

echo -e "Enter your username:"
read NAME

USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$NAME';")

if [[ -z $USER_ID_RESULT ]]
then
  USER_NAME=$NAME
  echo -e "Welcome, $USER_NAME! It looks like this is your first time here."
  USER_ID_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USER_NAME') RETURNING user_id;")
else
  USER_NAME=$(echo $($PSQL "SELECT username FROM users WHERE user_id='$USER_ID_RESULT';"))
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID_RESULT;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID_RESULT;")
  echo -e "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

# echo "SECRET_NUMBER: $SECRET_NUMBER"

while [[ $GUESS != $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi

  read GUESS
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
done


$PSQL "
  INSERT INTO 
  games(user_id, guesses)
  VALUES ($USER_ID_RESULT, $NUMBER_OF_GUESSES);
" > /dev/null

echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"