#!/bin/bash

set -e


# wait for API to be ready
MAX_ATTEMPTS=10
DELAY_BETWEEN_ATTEMPS=3

attempt=1

while true; do
  test=$(curl -s -I "http://starlake-api:9000/api/v1/health" | head -n 1 | cut -b 10-12)
  echo ">>>>> API ready ($attempt) ? <<<<<<"
  if [ "$test" == 200 ]; then
    echo ">>>>> API is ready <<<<<<"
    break;
  fi

  sleep "$DELAY_BETWEEN_ATTEMPS"

  attempt=$((attempt + 1))
  if [ "$attempt" -gt "$MAX_ATTEMPTS" ]; then
    exit 1
  fi
done



# wait for filestore to be ready
mkdir -p $FILESTORE_MNT_DIR
mount -v -o nolock $FILESTORE_IP_ADDRESS:/$FILESTORE_SHARE_NAME $FILESTORE_MNT_DIR
mount

export PGPASSWORD="${POSTGRES_PASSWORD}"
member_id=$(psql -h "${POSTGRES_HOST}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -w -t -A -c "SELECT id FROM public.slk_member WHERE email = 'admin@localhost.local'")
echo "Member ID: $member_id"

if [[ $member_id =~ ^[0-9]+$ ]]; then
    # List all zip files
    zips=$(find /projects -type f -regex '.*\.zip')

    for zip in $zips; do
        echo "Unzipping $zip"
        project_uuid=$(cat /proc/sys/kernel/random/uuid)
        mkdir -p /projects/$project_uuid
        unzip -o -d /projects/$project_uuid $zip
        ids=$(find /projects/$project_uuid -mindepth 1 -maxdepth 1 -type d)
        size=$(echo "$ids" | wc -l)
        if [ "$size" -eq 1 ]; then
            for id in $ids; do
                project_id=$(basename "$id")
                if [[ $project_id =~ ^[0-9]+$ ]]; then
                    project_name=$(basename "$zip" | cut -d. -f1)
                    if [ ! -d $FILESTORE_MNT_DIR/$member_id/$project_id ]; then
                        echo "Project $project_name will be created with id $project_id and UUID $project_uuid"
                        psql -v ON_ERROR_STOP=1 -h "${POSTGRES_HOST}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -w <<-EOSQL
INSERT INTO public.slk_project (id, code, "name", description, repository, active, deleted, created, updated, master, owner, owner_email, access, pat, airflow_role)
OVERRIDING SYSTEM VALUE 
VALUES($project_id, '$project_uuid', '$project_name', '$project_name', '', true, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, -1, $member_id, 'admin@localhost.local', 'ADMIN', '', 'DEV:OPS,STAGING:OPS,PROD:OPS');
INSERT INTO public.slk_project_props (id, project, properties, created, updated)
OVERRIDING SYSTEM VALUE 
VALUES($project_id, $project_id, '[{"envName":"__sl_ignore__"}]', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
EOSQL
                        echo "Move project $member_id/$project_id to target folder"
                        mkdir -p $FILESTORE_MNT_DIR/$member_id/$project_id
                        cp -r $id/* $FILESTORE_MNT_DIR/$member_id/$project_id
                        rm -rf /projects/$project_uuid
                        echo "Init git repository"
                        git -C "$FILESTORE_MNT_DIR/$member_id/$project_id" init
                        git -C "$FILESTORE_MNT_DIR/$member_id/$project_id" config user.email "admin@localhost.local"
                        git -C "$FILESTORE_MNT_DIR/$member_id/$project_id" config user.name "admin@localhost.local"
                        git -C "$FILESTORE_MNT_DIR/$member_id/$project_id" config pull.rebase false
                    else
                        echo "Project $project_id is already present in $FILESTORE_MNT_DIR/$member_id/"
                        rm -rf /projects/$project_uuid
                    fi
                else
                    echo "Project $project_id should consist of digits only"
                    rm -rf /projects/$project_uuid
                fi
            done
        else
            echo "Unzipped project should be placed in a single directory"
            rm -rf /projects/$project_uuid
        fi
    done
    echo "All projects have been unzipped"
    echo "You can now access Starlake at http://localhost:${SL_UI_PORT:-80}"
else
    exit 1
fi
