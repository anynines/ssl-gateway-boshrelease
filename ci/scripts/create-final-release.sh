set -o errexit # Exit immediately if a simple command exits with a non-zero status
set -o nounset # Report the usage of uninitialized variables

: ${BUCKET_URL?"Env variable CF_API not set"}

version=$(cat semver/version)

cd ssl-gateway-boshrelease
bosh -n create-release --force --final --version=$version --name=ssl-gateway --tarball=release-output/ssl-gateway-v$version.tar.gz

$sha=$(sha1sum release-output/*.tar.gz)

echo <<EOT >> release-versions.yml

- name: ssl-gateway-v$version.tar.gz
    version: $version
    url: $BUCKET_URL/ssl-gateway-v$version.tar.gz
    sha: $sha
EOT

git add .
git commit -m "Create final release version $version"
cd ..

echo "ssl-gateway" > release-output/name
echo $version > release-output/version
echo "CI/CD automated build" > release-output/body
