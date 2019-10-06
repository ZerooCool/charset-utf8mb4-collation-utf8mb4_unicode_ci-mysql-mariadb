#!/bin/bash

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
echo "Changer l'encodage / charset de la base de données : $database"
mysql -u $user -p$pass $database -s -e "ALTER DATABASE $database CHARACTER SET = $charset COLLATE = $collate;"

###########################
# Appliqué sur les tables #
###########################
for table in $(mysql $database -s --skip-column-names -e 'show tables')
do
  echo ''
  echo "Changer l'encodage / charset de la table : $table"
  mysql -u $user -p$pass $database -s -e "ALTER TABLE $table CHARACTER SET $charset COLLATE $collate"

  echo "Convertir l'encodage / charset de la table : $table"
  SET FOREIGN_KEY_CHECKS=0;
  mysql -u $user -p$pass $database -s -e "ALTER TABLE $table CONVERT TO CHARACTER SET $charset COLLATE $collate"
done

#######################
# Manque les colonnes #
#######################

###
###
###

echo ''
echo 'Conversion effectuée !'
echo ''

#############################
# Réparation / Optimisation #
#############################
echo 'Début de l'optimisation des tables !'
echo ''

mysqlcheck -u $user -p$pass $database --auto-repair --optimize

echo ''
echo 'Optimisation terminée !'