#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SELECT_SERVICE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Display available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Get customer input
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

  # If the choice is invalid
  if [[ -z $SERVICE_NAME ]]
  then
    SELECT_SERVICE "I could not find that service. What would you like today?"
  else
    MAKE_APPT
  fi
}

MAKE_APPT() {
  # get phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # is it existing customer?
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # new phone number
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get name for phone number
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    NEW_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # what time for cut
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME
  # insert appointment
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
  APPT_DETAILS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

SELECT_SERVICE
