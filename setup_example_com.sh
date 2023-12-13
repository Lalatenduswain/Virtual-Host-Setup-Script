#!/bin/bash

# Create directory and set ownership
sudo mkdir -p /var/www/html/example.com/public
sudo chown -R www-data:www-data /var/www/html/example.com/public

# Set permissions for the web root and its contents
sudo chmod -R 755 /var/www/html
sudo find /var/www/html -type f -exec chmod 644 {} \;

# Create index.php file
echo '<?php phpinfo(); ?>' | sudo tee /var/www/html/example.com/public/index.php > /dev/null

# Create and edit Apache virtual host file
sudo bash -c 'cat > /etc/apache2/sites-available/example.com.conf <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@example.com
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/html/example.com/public

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html/example.com/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL'

# Enable the site and restart Apache
sudo a2ensite example.com.conf
sudo systemctl restart apache2

# Add entry to /etc/hosts file
echo '127.0.0.1   example.com www.example.com' | sudo tee -a /etc/hosts > /dev/null

echo "Setup complete for example.com. Don't forget to configure DNS for external access."
