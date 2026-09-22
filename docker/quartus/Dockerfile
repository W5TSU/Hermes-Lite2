# Quartus Prime Lite (Linux), for building the Radioberry (Cyclone 10 LP)
# gateware variants headlessly. See README.md in this directory for how to
# get the installer staged here, build this image, and run a compile.
#
# Scope: compilation only (quartus_sh --flow compile / quartus_cpf). No JTAG
# programming support — that needs USB device passthrough for a USB-Blaster,
# which isn't set up here (see README.md if you need that later).
#
# The staged file (installers/qinst-lite-linux-*.run) is a Makeself-wrapped
# online installer ("qinst"), not the full Quartus package: it downloads the
# actual multi-GB payload over the network when run, using --components to
# pick device support (default components are quartus,questa_fse and default
# devices are cyclonev,max10 — Cyclone 10 LP is NOT in the defaults and must
# be requested explicitly). This means the RUN step below needs internet
# access during `docker build`, and the build will be slow the first time.
#
# Confirmed interactively against qinst-lite-linux-25.1std-1129.run's
# --help output on 2026-09-22 — this is not guesswork like the previous
# version of this file was.

FROM ubuntu:22.04

ARG QUARTUS_INSTALLER_NAME
ARG QUARTUS_INSTALL_DIR=/opt/intelFPGA_lite/quartus
ARG QUARTUS_COMPONENTS=quartus,cyclone10lp

RUN test -n "$QUARTUS_INSTALLER_NAME" || (echo "Build with --build-arg QUARTUS_INSTALLER_NAME=<file> (see README.md)" && exit 1)

# ca-certificates: qinst downloads the real payload over HTTPS at build time.
# qinst is Qt-based and dynamically links a set of Qt/X11 runtime libs even
# with --nox11 (it degrades to CLI-only *behavior*, but still needs the .so
# files present to load at all) — confirmed iteratively on 2026-09-22:
# libglib2.0-0 and libfontconfig1 were each hit one at a time as missing, so
# the rest of this list is the standard "headless Qt5 app" set rather than
# each having been individually confirmed required.
# locales: silences (harmless) en_US.UTF-8 locale warnings from qenv.sh.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      locales \
      libglib2.0-0 \
      libfontconfig1 \
      libfreetype6 \
      libsm6 \
      libice6 \
      libx11-6 \
      libxext6 \
      libxrender1 \
      libxtst6 \
      libxi6 \
      libxrandr2 \
      libxcursor1 \
      libxcomposite1 \
      libxdamage1 \
      libxfixes3 \
      libdbus-1-3 \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

WORKDIR /installers
COPY installers/ /installers/

# --accept/--noprogress/--nox11 are Makeself-wrapper-level flags (before --).
# Everything after -- goes to the embedded qinst tool itself:
#   --cli             force non-interactive CLI mode
#   --download-dir     scratch dir for the fetched payload (required by qinst)
#   --install-dir       final Quartus install location
#   --accept-eula       accept the Quartus Prime EULA (you already did this
#                       on Intel's download page to get this far)
#   --components        quartus + cyclone10lp only (skip questa_fse
#                       simulator, cyclonev/max10 devices we don't need)
#   --auto-install      install immediately after download
#   --bypass            skip the disk-space check (can misjudge container overlay fs)
#   --delete-downloads  don't keep the multi-GB fetched archive around after install
RUN chmod +x "/installers/${QUARTUS_INSTALLER_NAME}" && \
    "/installers/${QUARTUS_INSTALLER_NAME}" --accept --noprogress --nox11 -- \
      --cli \
      --download-dir /tmp/qinst-download \
      --install-dir "${QUARTUS_INSTALL_DIR}" \
      --accept-eula \
      --components "${QUARTUS_COMPONENTS}" \
      --auto-install \
      --bypass \
      --delete-downloads \
    && rm -rf /installers /tmp/qinst-download

# The actual bin/ subdirectory name has varied across Quartus releases
# (quartus/bin under the install dir historically) — verified once the
# install above actually succeeds; adjust here if quartus_sh isn't found.
ENV PATH="${QUARTUS_INSTALL_DIR}/quartus/bin:${PATH}"

# Sanity check that the CLI tools this repo's Makefiles call are present.
RUN quartus_sh --version && quartus_cpf --version

# make: the repo's variant Makefiles (gateware/variants/*/Makefile) invoke
# quartus_sh/quartus_cpf through `make`, which isn't in the base image.
# Placed after the expensive Quartus install layer so changes here don't
# invalidate that layer's build cache.
RUN apt-get update && apt-get install -y --no-install-recommends make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
CMD ["bash"]
