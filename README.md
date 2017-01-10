# wordpress-full-backup-crontab
Full Wordpress daily backup and upload to AWS S3 using crontab on Ubuntu/Linux environment

This shell script and cron job shows you how to backup WordPress mysql database and /uploads directory every day, upload the backup files to AWS S3, and delete backup files older than 24 hours.

## Setup
### Prepare directories for storing backups on ubuntu web server
```
cd ~
mkdir -p backup/mysql && mkdir -p backup/wp-uploads
```

### Setup AWS S3 bucket for storing backups on S3
- Register AWS S3 account and create a bucket named your website. Eg: abc.com 
- Create and IAM user that has access to S3 bucket above. Note down `aws_access_key_id` and `aws_secret_access_key`
- Setup AWS CLI on ubuntu web server:
```
sudo apt-get install awscli
```
- Config AWS CLI
```
aws configure
```
### Config shell script
- Create  `~/backup/wp-backup.sh` file with content of [wp-backup.sh](wp-backup.sh)
- Make shell script executable
```
cd ~/backup
chmod 700 wp-backup.sh
```
- Open backup.sh and update following values:
```
# For msyql database backup
user="mysql_user"
password="mysql_password"
host="localhost"
db_name="mysql_database"
backup_path="~/backup/mysql"
mysql_s3_path="s3://bucket_name/backup/mysql/"

# For uploads folder backup
upload_name="wp-uploads"
upload_folder="wp-website-root/wp-content/uploads"
upload_backup_path="~/backup/wp-uploads"
upload_s3_path="s3://backet_name/backup/wp-uploads/"
```

### Crontab
- Test to see if your shell script works
```
cd ~/backup
./wp-backup.sh
```
- When shell script is ready, update crontab file:
```
crontab -e
```
- You might need to choose the text editor for Crontab for first  time
- Add this command to crontab file will run the backup daily at 21:30:00 (Server time)
```
30 21 * * * ~/backup/wp-backup.sh
```

## Does it work?
- Check server folder to see if backup files have been created
- Check S3 bucket see if backup files have been uploaded

## Question & Contribution
- Feel free to report issue and contribute your idea.

## License
[MIT](LICENSE)
