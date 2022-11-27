#!/bin/sh
DATE=`date +%Y_%m_%d`
BASE_DIR=`echo "backup/$DATE"`
OUTPUT_FILE_NAME=`echo "compressed/$DATE.tar.zst"`

echo "[init] create destination directory: backup/misskey.yude.jp_${DATE}"
mkdir -p $BASE_DIR
mkdir -p compressed

echo "[clone] dump PostgreSQL database"
pg_dump -Fc -U misskey misskey > $BASE_DIR/misskey_db.dump

echo "[clone] clone .env.production"
cp -r ./.config $BASE_DIR/

echo "[clone] copy files/"
rsync -ax files $BASE_DIR/

echo "[clone] copy Redis dump"
cp ./redis/dump.rdb $BASE_DIR/

echo "[finalize] compress backup"
tar --preserve-permissions --use-compress-program zstd -cf $OUTPUT_FILE_NAME $BASE_DIR

echo "[finalize] delete temporary files"
rm -rf /app/backup/*

echo "Done! ^_^"
