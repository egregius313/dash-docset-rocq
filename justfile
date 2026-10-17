# Build the default Rocq docset.
build-docset:
    nu build.nu

# Remove images created by build-docset.
clean:
    nu build.nu clean
