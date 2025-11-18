This is a mix of bash scripting and an ansible playbook ( runs on local host )
To generate a ubuntu Autoinstalling ISO file to burn to usb flash drives.

This is meant to run on Debian-based distributions.

Make sure to customize the user-data under $Ver/template/user-data to your needs.
Don't be silly and keep the default password in this project.

To excute with no questions chmod +x new-image.sh; ./new-image.sh --auto