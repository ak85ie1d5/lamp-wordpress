#!/bin/bash

cd /var/www/html || exit

# Docker entrypoint for Bedrock only
if [ "${CMS}" == "bedrock" ]; then

  if [ ! -d "public" ]; then
    ln -s "${PWD}/${GIT_FOLDER}/web" "${PWD}/public"
  fi

  cd /var/www/html/"${GIT_FOLDER}" || exit

  # Check if .env` file exist
  if [ ! -f ".env" ]; then

        # Create `.env` file for Bedrock from `.env.example`
        cp "${OLDPWD}"/Docker/webserver/.env.example .env

        # Search and replace default values with those found in `.env` file.
        sed -i "s/DB_NAME='database_name'/DB_NAME=\'${DB_NAME}\'/" .env
        sed -i "s/DB_USER='database_user'/DB_USER=\'${DB_USER}\'/" .env
        sed -i "s/DB_PASSWORD='database_password'/DB_PASSWORD=\'${DB_PASSWORD}\'/" .env

        sed -i "s/# DB_HOST='localhost'/DB_HOST=\'${DB_HOST}\'/" .env
        sed -i "s/# DB_PREFIX='wp_'/DB_PREFIX=\'${DB_PREFIX}\'/" .env

        if [ "${WP_DEBUG}" == "false" ]; then
         sed -i "s/WP_ENV='development'/WP_ENV='production'/" .env
        fi

        escaped_WP_HOME=$(printf '%s\n' "${WP_HOME}" | sed -e 's/[\/&]/\\&/g')
        sed -i "s/WP_HOME='http:\/\/example.com'/WP_HOME='${escaped_WP_HOME}'/" .env

        sed -i "s/AUTH_KEY='generateme'/AUTH_KEY=\'${AUTH_KEY}\'/" .env
        sed -i "s/SECURE_AUTH_KEY='generateme'/SECURE_AUTH_KEY=\'${SECURE_AUTH_KEY}\'/" .env
        sed -i "s/LOGGED_IN_KEY='generateme'/LOGGED_IN_KEY=\'${LOGGED_IN_KEY}\'/" .env
        sed -i "s/NONCE_KEY='generateme'/NONCE_KEY=\'${NONCE_KEY}\'/" .env
        sed -i "s/AUTH_SALT='generateme'/AUTH_SALT=\'${AUTH_SALT}\'/" .env
        sed -i "s/SECURE_AUTH_SALT='generateme'/SECURE_AUTH_SALT=\'${SECURE_AUTH_SALT}\'/" .env
        sed -i "s/LOGGED_IN_SALT='generateme'/LOGGED_IN_SALT=\'${LOGGED_IN_SALT}\'/" .env
        sed -i "s/NONCE_SALT='generateme'/NONCE_SALT=\'${NONCE_SALT}\'/" .env
    fi
fi


# Docker entrypoint for Wordpress only
if [ "${CMS}" == "wordpress" ]; then

  if [ ! -d "public" ]; then
    ln -s "${PWD}/${GIT_FOLDER}" "${PWD}/public"
  fi

  cd /var/www/html/public || exit

  # Check if `wp-config.php` file exist
  if [ ! -f "wp-config.php" ]; then

      # Create `wp-config.php` file from `wp-config-sample.php`
      cp "${OLDPWD}"/Docker/webserver/wp-config-sample.php wp-config.php

      # Search and replace default values by **getenv()** function to get values in `.env` file.
      sed -i "s/define('DB_NAME', 'votre_nom_de_bdd');/define( 'DB_NAME', getenv('DB_NAME'));/" wp-config.php
      sed -i "s/define('DB_USER', 'votre_utilisateur_de_bdd');/define( 'DB_USER', getenv('DB_USER'));/" wp-config.php
      sed -i "s/define('DB_PASSWORD', 'votre_mdp_de_bdd');/define( 'DB_PASSWORD', getenv('DB_PASSWORD'));/" wp-config.php
      sed -i "s/define('DB_HOST', 'localhost');/define( 'DB_HOST', getenv('DB_HOST'));/" wp-config.php
      sed -i "s/define('AUTH_KEY',         'put your unique phrase here');/define( 'AUTH_KEY', getenv('AUTH_KEY') );/" wp-config.php
      sed -i "s/define('SECURE_AUTH_KEY',  'put your unique phrase here');/define( 'SECURE_AUTH_KEY', getenv('SECURE_AUTH_KEY'));/" wp-config.php
      sed -i "s/define('LOGGED_IN_KEY',    'put your unique phrase here');/define( 'LOGGED_IN_KEY', getenv('LOGGED_IN_KEY'));/" wp-config.php
      sed -i "s/define('NONCE_KEY',        'put your unique phrase here');/define( 'NONCE_KEY', getenv('NONCE_KEY'));/" wp-config.php
      sed -i "s/define('AUTH_SALT',        'put your unique phrase here');/define( 'AUTH_SALT', getenv('AUTH_SALT'));/" wp-config.php
      sed -i "s/define('SECURE_AUTH_SALT', 'put your unique phrase here');/define( 'SECURE_AUTH_SALT', getenv('SECURE_AUTH_SALT'));/" wp-config.php
      sed -i "s/define('LOGGED_IN_SALT',   'put your unique phrase here');/define( 'LOGGED_IN_SALT', getenv('LOGGED_IN_SALT'));/" wp-config.php
      sed -i "s/define('NONCE_SALT',       'put your unique phrase here');/define( 'NONCE_SALT', getenv('NONCE_SALT'));/" wp-config.php

      sed -i "s/\$table_prefix = 'wp_';/\$table_prefix = getenv('DB_PREFIX');/" wp-config.php

      sed -i "s/define('WP_DEBUG', false);/define( 'WP_DEBUG', getenv('WP_DEBUG'));/" wp-config.php
  fi
fi

exec "$@"