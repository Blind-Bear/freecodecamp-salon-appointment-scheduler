#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Opening phrase & service menu
  echo -e "\n~~~~~ Blind Bear's Salon ~~~~~\n"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

    # First prompt & get services
      echo -e "Thank you for choosing a blind bear for your hair necessities.\n\nWhat service can we offer you?\n" 
      SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

    # Display services
      echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE
      do
        echo "$SERVICE_ID) $SERVICE"
      done

    # Read service
      read SERVICE_ID_SELECTED

    # If input is not valid
      if [[ ! $SERVICE_ID_SELECTED =~ ^[1-7]+$ ]]
      then
      # Send to service menu
        SERVICE_MENU "That is not a valid service selection. Please try again."

      else
      # Get phone #
        SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        echo -e "\n You have selected,$SERVICE. What is your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # If customer not found on phone # lookup
        if [[ -z $CUSTOMER_NAME ]]
        then

        # Get new customer name
          echo -e "\nWe were unable to find a record of that phone number. What is your name?"
          read CUSTOMER_NAME

        # Insert new customer 
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          echo -e "/nThank you, $CUSTOMER_NAME. We now have you in our system as with a phone # of: $CUSTOMER_PHONE."
        fi

      # Get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # Get service time
        echo -e "Thank you, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g'). What time would you like to have your $(echo $SERVICE | sed -E 's/^ *| *$//g')?"
        read SERVICE_TIME

      # Input info into appointments
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # Appointment scheduled message
        echo -e "\nI have put you down for a $(echo $SERVICE | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."

      fi
    }

SERVICE_MENU
