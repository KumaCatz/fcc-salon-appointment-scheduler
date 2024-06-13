#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "$1\n"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  SERVICES_RESPONSE=$($PSQL "SELECT * FROM services")

  echo "$SERVICES_RESPONSE" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"

  else
    echo -e "\nWhat's your phone number?"

    read CUSTOMER_PHONE

    CUSTOMER_NAME=$(echo $($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'") | sed -r 's/^ *| *$//g')

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"

      read CUSTOMER_NAME

      INSERT_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g'), $CUSTOMER_NAME?"
    read SERVICE_TIME

    CUSTOMER_ID=$(echo $($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'") | sed -r 's/^ *| *$//g')

    echo "customer name: $CUSTOMER_NAME"
    echo "customer id: $CUSTOMER_ID"

    INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME.
  fi
}

MAIN_MENU