#!/bin/sh
set -e

mkdir -p /projects/dags /external_projects
chmod -R 777 /projects /external_projects
cat > /etc/exports <<EOF
/projects *(rw,sync,no_subtree_check,no_root_squash,insecure,fsid=0)
/projects/dags *(rw,sync,no_subtree_check,no_root_squash,insecure,fsid=1)
/external_projects *(rw,sync,no_subtree_check,no_root_squash,insecure,fsid=999)
EOF

# Démarrer rpcbind
echo "Starting rpcbind"
rpcbind
echo "rpcbind started"

# Démarrer rpc.statd
echo "Starting rpc.statd"
rpc.statd
echo "rpc.statd started"

# Appliquer les configurations d'exportation
echo "Applying exports"
exportfs -r
echo "Exports applied"

# Démarrer les services NFS
echo "Starting NFS services"
rpc.nfsd
echo "NFS services started"

echo "Starting NFS mountd (this may take some time)"
rpc.mountd -F
echo "NFS mountd started"

# Garder le conteneur en fonctionnement
exec /usr/sbin/rpc.nfsd
