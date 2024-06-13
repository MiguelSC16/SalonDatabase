#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){

  if [[ $1 ]]
    then
      echo -e "\n$1 What would you like today?"
    else
      echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT *FROM services")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then

      MAIN_MENU "That is not a valid service number."

    else

      SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      
      if [[ -z $SERVICE ]]
        then
          
          MAIN_MENU "I could not find that service."

        else
          
          echo -e "\nWhat's your phone number?"
          
          read CUSTOMER_PHONE
          
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
          
          if [[ -z $CUSTOMER_NAME ]]
            then
              
              echo -e "\nI don't have a record for that phone number, what's your name?"
              
              read CUSTOMER_NAME
              
              INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          fi
          
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          
          echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"

          read SERVICE_TIME

          INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")

          echo I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.
      fi

  fi

}
MAIN_MENU