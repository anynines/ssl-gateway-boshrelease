set -o errexit # Exit immediately if a simple command exits with a non-zero status
set -o nounset # Report the usage of uninitialized variables

: ${VERSION?"Env variable VERSION not set"}

cd ../
bosh create-release --final --name=ssl-gateway --version=$VERSION --tarball=/tmp/ssl-gateway-v$VERSION.tgz

sha=$(sha256sum /tmp/ssl-gateway-v$VERSION.tgz)

cat <<EOF > versions.yml

name: ssl-gateway-v$VERSION
  url: https://s3-eu-west-1.amazonaws.com/anynines-bosh-releases/ssl-gateway-v$VERSION.tgz
  sha: $sha
  version: $VERSION
EOF

aws s3 cp /tmp/ssl-gateway-v$VERSION.tgz s3://anynines-bosh-releases/ssl-gateway-v$VERSION.tgz
cd ..

