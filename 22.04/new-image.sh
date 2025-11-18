#!/bin/bash

# Created for creating an easy auto-install ubuntu 22.04 Jammy
# Created by Colton Morey 
# See https://www.pugetsystems.com/labs/hpc/ubuntu-22-04-server-autoinstall-iso/ for reference

# location where source-files are extracted
directory_path="./source-files"
# Set for jammy
FILE_NAME="jammy.iso"
ubuntu_source='https://releases.ubuntu.com/22.04.5/ubuntu-22.04.5-live-server-amd64.iso'
#!/bin/bash
# Loop through all command-line arguments
for arg in "$@"; do
    if [ "$arg" == "--auto" ]; then
        AUTO_FLAG=true
        break  # Exit the loop once the flag is found
    fi
done

if [ "$AUTO_FLAG" = true ]; then
    echo "The --auto flag was passed."
else
    echo "The --auto flag was not passed."
fi

if [ ! -d "$directory_path" ]; then
mkdir source-files
fi

if command -v wget >/dev/null 2>&1; then
    echo "wget is installed."
else
    echo "wget is not installed. Installing...."
    sudo apt install wget 
fi

download_noble(){
    if [ -n "$http_proxy" ]; then
        echo "The HTTP proxy is set: $http_proxy"
        wget -O $FILE_NAME -e use_proxy=yes http_proxy=$http_proxy $ubuntu_source
    else
        echo "The HTTP_PROXY variable is not set."
        wget $ubuntu_source
    fi
}

if [ -e "$FILE_NAME" ]; then
    echo "File found: $FILE_NAME"
    # Use find to locate files older than 5 days and remove them
    find "./" -type f -name "$FILE_NAME" -mtime +5 -exec rm {} \;
    echo "Older files removed."
    download_noble
else
    echo "File not found: $FILE_NAME"
    download_noble
fi

prompt_yes_no() {
local answer="" 
while [[ "$answer" != "Y" && "$answer" != "y" && "$answer" != "N" && "$answer" != "n" ]]; do
    # Ask if user wants to remove the source files folder recursively
    read -p "Do you want to remove proceed? (Y/N): " answer
    # Normalize the input to lowercase to not make my life hell
    case "${answer,,}" in
        y) 
            
            echo "Removing and starting clean..."
            rm -rf "$directory_path"
            ;;
        n)
            echo "You chose No."
            exit 0
            
            ;;
        *)
            echo "Invalid input. Please enter 'Yes' or 'No'."
            ;;
    esac
done
}


if [ "$1" == "--auto" ]; then
    echo "The --auto flag was passed."
    echo "Removing and starting clean..."
    rm -rf "$directory_path"
    #  Remove the boot file if it lives. 
        if [ -d "./BOOT" ]; then
        rm -r ./BOOT
        fi
fi
if [ -d "$directory_path" ]; then
    prompt_yes_no
fi

# Do a check and see if the package is installed for 7zip
if command -v 7z >/dev/null 2>&1; then
    echo "7zip is installed."
    sleep 0.5
else
    echo "7zip is not installed. Installing...."
    sudo apt install 7zip 
fi
#extract das ISO!
7z -y x noble.iso -osource-files

#move the boot file up a level and change the name to make it easier to script with 
mv  source-files/'[BOOT]' ./BOOT

# Do a check and see if the package is installed for xorriso
if command -v xorriso >/dev/null 2>&1; then
    echo "xorriso is installed."
    sleep 0.5
else
    echo "xorriso is not installed. Installing...."
    sudo apt install xorriso 
fi

# Do a check and see if the package is installed for ansible
if command -v ansible-playbook >/dev/null 2>&1; then
    echo "Anisible is installed."
    sleep 0.5
else
    echo "Ansible is not installed. Installing...."
    sudo apt install ansible
fi

ansible-playbook main.yaml --extra-vars "ubuntu_iso=$FILE_NAME"
/bin/bash build.sh

rm -rf source-files
rm -rf BOOT
rm -r $FILE_NAME
exit 0

