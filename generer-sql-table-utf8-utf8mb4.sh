 #!/usr/bin/env bash
 HOST="localhost"
 USER="root"
 DATABASE=""
 CHARSET="utf8mb4"
 COLLATION="utf8mb4_unicode_ci"
 
 tables() {
   local query="SELECT CONCAT(TABLE_SCHEMA, '.', TABLE_NAME) AS \`table\` \
     FROM INFORMATION_SCHEMA.TABLES \
     WHERE TABLE_SCHEMA=\"${DATABASE}\" AND TABLE_TYPE=\"BASE TABLE\""
   mysql -h ${HOST} -u ${USER} -p ${DATABASE} -e "${query}"
 }
 
 generate_sql() {
   # Désactiver FK contrôles pendant la conversion.
   echo "SET foreign_key_checks = 0;";
 
   tables | while read -r table; do
     echo "ALTER TABLE ${table} CONVERT TO CHARACTER SET ${CHARSET} COLLATE ${COLLATION};"
   done
 
   # Réactiver FK contrôles suite à la conversion.
   echo "SET foreign_key_checks = 1;";
 }
 generate_sql

 # Les 5 lignes suivantes doivent être retirées !
 
## remove this
#Enter password:
#
## remove this
#ALTER TABLE table CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

#Le code SQL obtenu peut être exécuté dans MariaDB pour modifier le Charset et la Collation des tables.
# Source : https://github.com/Juddling/mysql-charset
