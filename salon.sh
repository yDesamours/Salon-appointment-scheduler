#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~Salon~~~~~\n"
echo -e "Welcome! Here are our services:\n"



MAIN_MENU(){
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  # get all services
  echo "$($PSQL "SELECT * FROM services")" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
   # print each service in one line
    echo "$SERVICE_ID) $SERVICE_NAME" 
  done

  # what does the customer want
  read SERVICE_ID_SELECTED
  #service not correct
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "We don't offer that service. Choose one from the list."
  fi

  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # service not found
  if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "We don't offer that service. Choose one from the list."
    #service found
    else
      #get phone number
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      #get customer name
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
     echo $CUSTOMER_ID
      # customer not found
      if [[ -z $CUSTOMER_ID ]]
        #get new customer name
        then 
          echo -e "\nWhat is your name?"
          read CUSTOMER_NAME
          #register new customer
          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          #get new id
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi
      # ask for time
      echo -e "\nWhen will you come for this service?"
      read SERVICE_TIME
      #add the appointment
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      #confirm
      CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")"
      echo "I have put you down for a $(echo $SERVICE_NAME | sed 's/ //') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //')."
  fi
  exit 
}

MAIN_MENU

