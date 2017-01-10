# Configurations
# Database credentials
user="mysql_user"
password="mysql_password"
host="localhost"
db_name="mysql_database"
backup_path="~/backup/mysql"
mysql_s3_path="s3://bucket_name/backup/mysql/"
date=$(date +"%d-%b-%Y")

# Run commands
# Set default file permissions
umask 177
# Dump database into SQL file
mysqldump --user=$user --password=$password --host=$host $db_name > $backup_path/$db_name-$date.sql
if [ "$?" -eq 0 ]
then
    echo "Export success"
    echo "Compressing..."
    cd $backup_path
    tar cfvz $db_name-$date.sql.gz $db_name-$date.sql
    echo "Uploading S3..."
    aws s3 cp $backup_path/$db_name-$date.sql.gz $mysql_s3_path
    echo "Backup mysql gz file to S3 done."
else
    echo "Mysqldump encountered a problem look in database.err for information"
fi
# Delete files older than 1 days
echo "cleanup old backups..."
find $backup_path/* -type f -mtime +3 -exec rm {} ;


# Configurations
upload_name="wp-uploads"
upload_folder="wp-website-root/wp-content/uploads"
upload_backup_path="~/backup/uploads"
upload_s3_path="s3://backet_name/backup/wp-uploads/"

# Run commands
echo "Backing up uploads folder..."
echo "Start Compressing..."
cd $upload_backup_path
tar cfvz $upload_name-$date.gz $upload_folder
echo "Done Compressing."
aws s3 cp $upload_backup_path/$upload_name-$date.gz $upload_s3_path
# Delete files older than 1 days
echo "cleanup old backups..."
find $upload_backup_path/* -type f -mtime +3 -exec rm {} ;
