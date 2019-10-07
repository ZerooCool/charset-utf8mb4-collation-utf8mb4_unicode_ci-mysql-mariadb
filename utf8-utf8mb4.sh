#!/bin/bash
######################################
# Configurer la base de données MariaDB :
# Ajouter les lignes suivantes dans la configuration de MariaDB ou de MySQL
# pour supporter des clés plus grandes nécessaires lors de l'utilisation de UTF8MB4.
# La conversion de UTF8 vers UTF8MB4 pourra se faire sans retours erreurs
# ou avertissements de longueur de clé dépassant la limite autorisée.
#
# Éditer la configuration de MariaDB.
# sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
#
# [mysqld]
# collation_connection s’affiche sous la forme utf8mb4_unicode_ci au lieu de utf8mb4_general_ci
# lors de l’exécution d’une requête SHOW VARIABLES LIKE 'collation%'
# character-set-client-handshake=FALSE
# character-set-server  = utf8mb4
# collation-server      = utf8mb4_unicode_ci
#
# Ce groupe n'est lu que par les serveurs MariaDB-10.3.
# Si vous utilisez le même fichier .cnf pour MariaDB de versions différentes,
# utiliser ce groupe pour les options que les anciens serveurs ne comprennent pas.
# [mariadb-10.3]
# innodb_file_format = Barracuda
# innodb_file_per_table = 1
# innodb_default_row_format = dynamic
# innodb_large_prefix = 1
#
# Redémarrer le service MariaDB.
# sudo service mysql restart

######################################
# Identifiants de la base de données #
######################################
database='database'
user='user'
pass='pass'

######################
# Le nouvel encodage #
######################
charset='utf8mb4'
collate='utf8mb4_unicode_ci'

###################################
# Appliqué sur la base de données #
###################################
echo "Changement de l'encodage / charset de la base de données : $database"
mysql -u $user -p$pass $database -s -e "ALTER DATABASE $database CHARACTER SET = $charset COLLATE = $collate;"

for table in $(mysql $database -s --skip-column-names -e 'show tables')
do
###########################
# Appliqué sur les tables #
###########################
  echo ''
  echo "Changement de l'encodage / charset de la table : $table"
  mysql -u $user -p$pass $database -s -e "ALTER TABLE $table CHARACTER SET $charset COLLATE $collate"

#############################
# Appliqué sur les colonnes #
#############################
  echo "Convertir l'encodage / charset de la table : $table"
  SET FOREIGN_KEY_CHECKS=0;
  mysql -u $user -p$pass $database -s -e "ALTER TABLE $table CONVERT TO CHARACTER SET $charset COLLATE $collate"
done

echo ''
echo 'Conversion effectuée !'
echo ''

#############################
# Réparation / Optimisation #
#############################
echo "Début de l'optimisation des tables !"
echo ''

mysqlcheck -u $user -p$pass $database --auto-repair --optimize

echo ''
echo "Optimisation terminée !"

# Appliquer le changement d'encodage dans la configuration du programme concerné.
# Pour Gitea, modifier le fichier de configuration /etc/gitea/app.ini

# Les caractères unicode peuvent être utilisés avec l'encodage de caractères UTF8MB4.
# Unicode Character 'DASH SYMBOL' (U+1F4A8) : 💨
# DASH : http://www.unicode-symbol.com/u/1F4A8.html
