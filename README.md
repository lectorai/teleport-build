# teleport-build

Builds [Teleport](https://github.com/gravitational/teleport) from its public sources under the AGPL-3.0 and packages it as a container image.

Teleport's source is AGPL-3.0. Gravitational's own prebuilt Community Edition binaries come under a separate [Community Edition License](https://github.com/gravitational/teleport/blob/master/build.assets/LICENSE-community) with company size limits. As Gravitational puts it in the [announcement of that license](https://goteleport.com/blog/teleport-community-license/): "Companies or individuals are welcome to compile the source code under AGPLv3 terms." This repository does exactly that, without any changes to the code.

## What is built

- **Release archives** (linux-amd64): `teleport`, `tctl`, `tsh`, `tbot`, `fdpass-teleport` and `teleport-update`, built with upstream's own release target `make -C build.assets release-amd64` (CentOS 7 buildbox, same build tags as the official release, static libfido2). Published as GitHub releases of this repository, tagged like upstream (e.g. `v18.11.10`), with `checksums.txt`.
- **Container image** `teleport:<version>` (version without `v`), pushed to `europe-west3-docker.pkg.dev/lector-ai/images/teleport` (needs the repository secret `GOOGLE_APPLICATION_CREDENTIALS_JSON_BASE64`) and also provided as a `docker save` archive in the workflow run's `image` artifact (`docker load < teleport-image-*.tar.gz`). The `Dockerfile` mirrors upstream's `build.assets/charts/Dockerfile-distroless` (distroless base, dumb-init, PAM/audit libraries, same entrypoint) and takes the binaries from the release archive.

The archives and the image ship the AGPL-3.0 text in place of the Community Edition license.

Differences to Gravitational's builds:

- `teleport-update` has no embedded artifact signing keys, since these builds are not signed.
- Only linux-amd64. arm64 works the same way with `release-arm64` on an arm64 runner.

## Building

Actions → *Build Teleport* → *Run workflow*, with the upstream release tag (e.g. `v18.11.10`). The workflow builds, publishes the release, then builds and pushes the image. *Build Teleport image* repackages an existing release on its own.

Every upstream security release needs its own run.

## Using it

- Use the official Helm charts (`teleport-cluster`, `teleport-kube-agent` from https://charts.releases.teleport.dev) and set `image` to `europe-west3-docker.pkg.dev/lector-ai/images/teleport`. The chart defaults point at the Community Edition images.
- Disable managed updates (e.g. `updater.enabled=false` in `teleport-kube-agent`). They download from Gravitational's CDN by default, and this `teleport-update` cannot verify signatures.
- `go version -m teleport` shows module path, build tags and dependencies, for comparing a binary against upstream.

## License

The build scripts in this repository are licensed under the AGPL-3.0 ([LICENSE](LICENSE)), like the Teleport sources they build. The corresponding source of every release is the upstream tag of the same name plus this repository.
