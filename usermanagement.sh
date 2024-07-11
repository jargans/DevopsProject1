#!/bin/bash

add_user() {
  # Prompt for the username
  read -p "Enter the new username: " username

  # Check if the username is provided
  if [ -z "$username" ]; then
    echo "Error: Username is required."
    return 1
  fi

  # Check if the username already exists
  if id "$username" &>/dev/null; then
    echo "Error: User '$username' already exists."
    return 1
  fi

  # Prompt for the password
  read -s -p "Enter the password for $username: " password
  echo
  read -s -p "Confirm the password: " password_confirm
  echo

  # Check if passwords match
  if [ "$password" != "$password_confirm" ]; then
    echo "Error: Passwords do not match."
  else
        sudo useradd -m -p "$password" "$username"
        echo "User account '$username' created successfully."
  fi
}

# Function to delete a user account interactively
delete_user() {
  # Prompt for the username to delete
  read -p "Enter the username to delete: " username

  # Check if the username is provided
  if [ -z "$username" ]; then
    echo "Error: Username is required."
    return 1
  fi

  # Check if the user exists
  if ! id "$username" &>/dev/null; then
    echo "Error: User '$username' does not exist."
    return 1
  else
         sudo userdel -r "$username" 2>/dev/null
  fi
# Output success message
  echo "User '$username' deleted successfully."
}

# Function to modify the user's password
modify_user() {
    # Prompt for the username
    echo "Enter the username whose password you want to change:"
    read username

    # Check if the user exists
    if id "$username" &>/dev/null; then
        echo "User $username exists."

        # Prompt for the new password
        echo "Enter the new password for $username:"
        read -s new_password

        # Confirm the new password
        echo "Confirm the new password for $username:"
        read -s confirm_password

        # Check if the passwords match
        if [ "$new_password" == "$confirm_password" ]; then
            # Change the password
            echo "$username:$new_password" | sudo chpasswd
            if [ $? -eq 0 ]; then
                echo "Password for $username has been successfully changed."
            else
                echo "Failed to change the password for $username."
            fi
        else
            echo "Passwords do not match. Please try again."
        fi
    else
        echo "User $username does not exist."
    fi
}
# Function to create a new group
create_group() {
    # Prompt for the groupname"
    read -p "Enter Groupname" groupname
     # Check if the groupname is provided
    if [ -z "$groupname" ]; then
        echo "Error: Groupname is required."
        return 1
    fi
    # Check if the group already exists
    if grep -q "^${groupname}:" /etc/group; then
        echo "Group '$groupname' already exists."
        return 1
    fi

    # Create the group
    sudo groupadd "$groupname"
    if [ $? -eq 0 ]; then
        echo "Group '$groupname' created successfully."
    else
        echo "Failed to create group '$groupname'."
    fi
}

# Function to delete a group
delete_group() {
  # Prompt for the groupname"
    read -p "Enter Groupname" groupname

  # Check if the group name is provided
  if [ -z "$groupname" ]; then
    echo "Error: Group name is required."
    return 1
  fi

  # Check if the group exists
  if ! grep -q "^$groupname:" /etc/group; then
    echo "Error: Group '$groupname' does not exist."
    return 1
  fi

  # Delete the group
  sudo groupdel "$groupname"

  # Check if the groupdel command was successful
  if [ $? -ne 0 ]; then
    echo "Error: Failed to delete group '$groupname'."
    return 1
  fi

  # Output success message
  echo "Group '$groupname' deleted successfully."
  return 0
}

view_users()
{
        awk -F: '$3 >= 1000 {print $1}' /etc/passwd
}
view_groups()
{
        awk -F: '($3 >= 1000 && $3 < 65534) ' /etc/group
}

#!/bin/bash

# Function to add user to group
add_user_to_group() {
  read -p "Enter the username to add to group" username
  read -p "Enter the groupname in which you want to add user to group" groupname

  # Check if both username and groupname are provided
  if [ -z "$username" ] || [ -z "$groupname" ]; then
    echo "Error: Username and groupname are required."
    return 1
  fi

  # Check if the user exists
  if ! id "$username" &>/dev/null; then
    echo "Error: User '$username' does not exist."
    return 1
  fi

  # Check if the group exists
  if ! grep -q "^$groupname:" /etc/group; then
    echo "Error: Group '$groupname' does not exist."
    return 1
  fi

  # Add user to group
  sudo usermod -aG "$groupname" "$username"

  # Check if usermod command was successful
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add user '$username' to group '$groupname'."
    return 1
  fi

  # Output success message
  echo "User '$username' added to group '$groupname' successfully."
  return 0
}

#!/bin/bash

# Function to remove user from group
remove_user_from_group() {
  read -p "Enter the username to remove from group" username
  read -p "Enter the groupname from which you want to remove the user" groupname
  # Check if both username and groupname are provided
  if [ -z "$username" ] || [ -z "$groupname" ]; then
    echo "Error: Username and groupname are required."
    return 1
  fi

  # Check if the user is a member of the group
  if ! groups "$username" | grep -q "\b$groupname\b"; then
    echo "Error: User '$username' is not a member of group '$groupname'."
    return 1
  fi

  # Remove user from group
  sudo gpasswd -d "$username" "$groupname"

  # Check if gpasswd command was successful
  if [ $? -ne 0 ]; then
    echo "Error: Failed to remove user '$username' from group '$groupname'."
    return 1
  fi

  # Output success message
  echo "User '$username' removed from group '$groupname' successfully."
  return 0
}

take_backup(){
<<comment
This scripts will take backup from source to target
comment

src_dir="/home/ubuntu/src"

backup_filename="backup_$(date +%Y-%m-%d-%H-%M-%S)"

tgt_dir="/home/ubuntu/backups/${backup_filename}"

echo "Backup Started"

echo "Backing up to $backup_filename ..."

zip -r "${tgt_dir}.zip" "$src_dir"

local backups=($(ls -t "/home/ubuntu/backups/backup_"*.zip 2>/dev/null))

if [ "${#backups[@]}" -gt 3 ]; then
        local backups_to_remove=("${backups[@]:3}")
        for backup in "${backups_to_remove[@]}"; do
            rm -f "$backup"
        done
    fi

echo "Backup Complete"
}

echo "1.Create User"
echo "2.View Users"
echo "3.Delete User"
echo "4.Change User Password"
echo "5.Create Group"
echo "6.View Groups"
echo "7.Delete Group"
echo "8.Add Users to Group"
echo "9.Remove Users from Group"
echo "10.Take Backup"
read -p "Enter your choice [1-10]: " choice
case $choice in
        1) add_user;;
        2)view_users;;
        3)delete_user;;
        4)modify_user;;
        5)create_group;;
        6)view_groups;;
        7)delete_group;;
        8)add_user_to_group;;
        9)remove_user_from_group;;
        10)take_backup;;
        *)
    echo "Invalid choice. Please select a number between 1 and 10."
    ;;
esac
