
cd acceptance-tests
./run-testsuite.sh
cd ..

bosh create-release --final --name=ssl-gateway --version=$VERSION --tarball=/tmp/ssl-gateway-v$VERSION.tgz

sha=$(sha256sum /tmp/ssl-gateway-v$VERSION.tgz)

cat <<EOF > release-versiony.yml

name: ssl-gateway-v$VERSION
  url: https://s3-eu-west-1.amazonaws.com/anynines-bosh-releases/ssl-gateway-v$VERSION.tgz
  sha: $sha
  version: $VERSION
EOF

git add .
git commit -m "Create new final release ssl-gateway-v$VERSION"

