#!/bin/bash

database='database'
user='user'
pass='pass'

charset='utf8mb4'
collate='utf8mb4_unicode_ci'

echo "Changer l'encodage / charset de la base de données: $database"
mysql -u $user -p$pass $database -s -e "ALTER DATABASE $database CHARACTER SET = $charset COLLATE = $collate;"

for table in $(mysql $database -s --skip-column-names -e 'show tables')
do
  echo ''
  echo "Changing charset of table: $table"
  mysql -u $user -p$pass $database -s -e "ALTER TABLE $table CHARACTER SET $charset COLLATE $collate"

  echo "Converting charset of table: $table"
  
  SET FOREIGN_KEY_CHECKS=0;
  
  mysql -u $user -p$pass $database -s -e "ALTER TABLE $table CONVERT TO CHARACTER SET $charset COLLATE $collate"
done

echo ''
echo 'Conversion done!'
echo ''
echo 'Optimizing tables...'
echo ''

mysqlcheck -u $user -p$pass $database --auto-repair --optimize

echo ''
echo 'Done! Have a nice day! ;)'
