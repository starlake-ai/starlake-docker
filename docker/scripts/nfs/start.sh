#!/bin/sh
set -e

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
