#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  # show services
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES_LIST" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # serive selected
  read SERVICE_ID_SELECTED

  # check service if exist
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  SERVICE_NAME_SELECTED=$(echo "$SERVICE_NAME_SELECTED" | xargs)

  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    echo -e "\nI could not find that service. What would you like today?\n"
    MAIN_MENU
  else
    # ask for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_DATA=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    if [[ -z $CUSTOMER_DATA ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');" >/dev/null

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      CUSTOMER_ID=$(echo "$CUSTOMER_ID" | xargs)
    else
      IFS="|" read CUSTOMER_ID CUSTOMER_NAME <<< "$CUSTOMER_DATA"
      CUSTOMER_ID=$(echo "$CUSTOMER_ID" | xargs)
      CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | xargs)
    fi

    # Visit time
    echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Add visit
    $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" >/dev/null

    echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU