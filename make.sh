#!/bin/sh -e

VERSION="${1:?usage: make.sh <version>}"

repo=boostorg/boost
tag="boost-$VERSION"
artifact="$tag-cmake.tar.xz"
url="https://github.com/$repo/releases/download/$tag/$artifact"

rm -rf "$artifact" "$tag"
echo "-- Downloading"
curl -fLO "$url"
echo "-- Extracting"
tar xf "$artifact"
rm "$artifact"

cd "$tag"
find . -type d \( -name "doc" -o -name "test" -o -name "example" \) -exec rm -rf {} \; || :

# Additional libs to delete
for lib in phoenix math json spirit; do
    rm -rf libs/$lib
done

cd ..
artifact="$tag.tar"
tar cf "$artifact" "$tag"
zstd -10 "$artifact"

rm -rf "$artifact" "$tag"

mkdir -p artifacts
mv "$artifact.zst" artifacts

artifact="artifacts/$artifact.zst"

echo "-- Made artifact"

# now release
gh release create "$VERSION" -t "Boost $VERSION" --notes "Debloated Boost $VERSION" || :
gh release upload --clobber "$VERSION" "$artifact"
