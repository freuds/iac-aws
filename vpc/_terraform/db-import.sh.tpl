ssh -i /home/ubuntu/.ssh/id_key ${ db_host } 'sudo docker exec key.app-mariadb \
  sh -c \"mysqldump -u ${ db_user } -p\"${ db_password }\" \
  --single-transaction ${ db_name } \" > /mnt/data_data_export.sql'
scp -i /home/ubuntu/.ssh/id_key ${ db_host }:/mnt/data_data_export.sql /tmp/.
