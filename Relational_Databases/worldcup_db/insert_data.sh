#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate games and teams
$PSQL "TRUNCATE games, teams RESTART IDENTITY;"

# Read games.csv and insert to db
tail -n +2 games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do

  # Get/Insert winner team id
  WINNER_ID=$($PSQL "
    WITH ins AS (
      INSERT INTO teams(name)
      VALUES('$WINNER')
      ON CONFLICT (name) DO NOTHING
      RETURNING team_id
    )
    SELECT team_id FROM ins
    UNION
    SELECT team_id FROM teams WHERE name='$WINNER'
    LIMIT 1;
  ")

  # Get/Insert opponent team id 
  OPPONENT_ID=$($PSQL "
    WITH ins AS (
      INSERT INTO teams(name)
      VALUES('$OPPONENT')
      ON CONFLICT (name) DO NOTHING
      RETURNING team_id
    )
    SELECT team_id FROM ins
    UNION
    SELECT team_id FROM teams WHERE name='$OPPONENT'
    LIMIT 1;
  ")

  # Insert game row
  $PSQL "
    INSERT INTO 
    games(  year,   winner_id,    opponent_id,    winner_goals, opponent_goals, round)
    VALUES( $YEAR,  $WINNER_ID,   $OPPONENT_ID,   $WGOALS,      $OGOALS,        '$ROUND');
  " > /dev/null

done