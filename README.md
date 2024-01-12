# lamp-wordpress

Environnement LAMP pour WordPress et Bedrock propulsé par docker-compose

## Prérequis

À installer en local :
- Docker
- docker-compose
- (Optionnel) NodeJS

Informations à reprendre du serveur en production :
- La version de PHP. Modifier le fichier `/Docker/php/Dockerfile` comme dans l'exemple (pour utiliser PHP 8.2 avec Apache) :
    ```dockerfile
    FROM php:8.2-apache

    ...
    ```

- Le SGBDR et sa version. Modifier le fichier `/Docker/mariadb/Dockerfile` comme dans l'exemple (pour utiliser MariaDB 10.5.21) :
    ```dockerfile
    FROM mariadb:10.5.21

    ...
    ```
Pour utiliser **MySQL** à la place de **MariaDB**, modifier le fichier `docker-compose.yml` en décommettant les lignes propres à **MySQL** et en commentant (supprimant) celles qui font référence à **MariaDB**.

## Installation

1. Cloner ce dépôt dans un dossier :
    ```shell
    $ git clone git@github.com:ak85ie1d5/lamp-wordpress.git mon_site
    ```

2. Cloner le site WordPress/Bedrock à la racine du dossier `mon_site` :
    ```shell
    $ cd mon_site
    $ git clone git@github.com:git_user/my-wordpress-project.git
    ```

3. Dupliquer et renommer le fichier `.env_sample` en `.env` et renseigner toutes les variables :
    ```shell
    $ cp .env.sample .env
    $ nano .env
    ```
   Pour la variable `WP_HOME`, il faut ajouter le numéro de port HTTP ou HTTPS utilisé par le conteneur **php**.

4. Exporter la base de données du site depuis le serveur de production (ou de pré-production), puis enregistrer le fichier dans `/Docker/mariadb/database/`.

5. Créer les images Docker :
    ```shell
    $ docker-compose build
    ```
6. (Optionnel) Il est possible de lancer un conteneur avec l'image de NodeJS. Retirer les **#** dans le fichier `docker-composer.yml`, puis préciser le numéro de version de NodeJS désiré.

7. Lancer les conteneurs Docker :
    ```shell
    $ docker-compose up -d
    ```

8. (Optionnel - pour Bedrock uniquement) Entrer dans le conteneur **php** et installer Bedrock :
    ```shell
    $ docker exec -ti mon_site-php-1 bash
    # dans le conteneur mon_site-php-1
    $ cd my-wordpress-project
    $ composer install
    ```

9. (Optionnel - s'il faut remplacer l'URL du site dans la base de données) Entrer dans le conteneur **php** et lancer la commande suivante pour rechercher et remplacer l'URL du site en production par une URL pour le développement :
    ```shell
    $ docker exec -ti mon_site-php-1 bash
    # dans le conteneur mon_site-php-1
    $ cd my-wordpress-project
    $ wp search-replace 'http://example.com' 'http://example.test' --recurse-objects --skip-columns=guid --skip-tables=wp_users
    ```

10. Récupérer les medias depuis le serveur de production (ou de pré-production) :

Les médias se trouvent dans le dossier `/mon_site/wp-content/uploads` dans le cas d'une WordPress classique et dans `/mon_site/web/app/uploads` dans le cas de Bedrock.

Il est possible d'afficher les medias dans le navigateur sans les récupérer en local. Pour cela, il suffit d'ajouter les instructions dans le fichier `.htacess` à la racine du site :
```apacheconf
RewriteCond %{HTTP_HOST} ^www\.mon_site\.local$ [NC]
# WordPress classique
RewriteRule ^wp-content/uploads/(.*)\.(jpg|jpeg|png|gif|svg|pdf|webp|mp4)$ https://www.mon_site.fr/wp-content/uploads/$1.$2 [R=301,L]
# Bedrock
RewriteRule ^app/uploads/(.*)\.(jpg|jpeg|png|gif|svg|pdf|webp|mp4)$ https://www.mon_site.fr/app/uploads/$1.$2 [R=301,L]
```
Dans cet exemple **www.mon_site.local** et le nom de domaine local et **www.mon_site.fr** est le site en production.