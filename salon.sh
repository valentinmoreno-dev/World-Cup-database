#! /bin/bash

# Variable for executing PostgreSQL commands
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display services and prompt for selection
show_services() {
  echo -e "\nWelcome to the Salon! Here are our services:\n"
  
  # Display the list of services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  # Prompt for service selection
  echo -e "\nPlease select a service by entering the corresponding number:"
  read SERVICE_ID_SELECTED

  # Check if the selected service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    # Invalid service, show services again
    echo -e "\nInvalid service selection. Please try again."
    show_services
  else
    # Proceed with valid service
    handle_appointment $SERVICE_ID_SELECTED "$SERVICE_NAME"
  fi
}

# Function to handle appointment booking
handle_appointment() {
  local SERVICE_ID_SELECTED=$1
  local SERVICE_NAME=$2

  # Prompt for phone number
  echo -e "\nEnter your phone number:"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    # Customer not found, prompt for name
    echo -e "\nYou are a new customer. Please enter your name:"
    read CUSTOMER_NAME

    # Insert new customer into the database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Get customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Prompt for appointment time
  echo -e "\nEnter the time for your appointment:"
  read SERVICE_TIME

  # Insert appointment into the database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirm the appointment
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ |/ /')
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Start the script by showing services
show_services

