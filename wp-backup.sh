# Configurations
# Database credentials
mysql_user="mysql_user"
mysql_password="mysql_password"
mysql_host="host"
mysql_database="mysql_database"
local_backup_path="/sites/folder/regular-backup"
s3_backup_path="s3://bucket-name/regular-backup"
d=$(date +"%d-%b-%Y")
site_folder="/sites/folder"
www_folder=$site_folder"/www"
wp_content_folder=$www_folder"/wp-content"
site_name="site_name"

# Run commands
# Set default file permissions
umask 177
# Dump database into SQL file
echo "Export database..."
mysqldump --user=$mysql_user --password=$mysql_password --host=$mysql_host $mysql_database > $local_backup_path/$mysql_database-$d.sql
if [ "$?" -eq 0 ]
then
    echo "Compressing..."
    cd $local_backup_path
    sudo tar cf $mysql_database-$d.sql.gz $mysql_database-$d.sql
else
    echo "Mysqldump encountered a problem look in database.err for information"
fi

echo "Compressing wp-content folder..."
cd $www_folder
sudo tar cf "wp-content"-$d.gz "wp-content"
sudo mv "wp-content"-$d.gz $local_backup_path"/"
echo "Done compress wp-content folder"

echo "Compressing wp-config.php..."
cd $www_folder
sudo tar cf "wp-config.php"-$d.gz "wp-config.php"
sudo mv "wp-config.php"-$d.gz $local_backup_path"/"
echo "Done compressing wp-config.php..."

echo "Bundle"
cd $local_backup_path
sudo tar cf $site_name-$d.gz $mysql_database-$d.sql.gz "wp-content"-$d.gz "wp-config.php"-$d.gz
echo "Cleaning..."
sudo rm -rf $mysql_database-$d.sql.gz "wp-content"-$d.gz "wp-config.php"-$d.gz
echo "Done Cleaning..."
echo "Done Bundle"

# Clean old backup locally
sudo find $local_backup_path/* -type f -mtime +0 -exec rm {};

# Upload S3
sudo aws s3 cp $local_backup_path/$site_name-$d.gz $s3_backup_path"/"
