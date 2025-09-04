# Use the official Ubuntu 18.04 base image from Docker Hub.
# This is the starting point for our new image.
FROM ubuntu:18.04

# Use the `ARG` instruction to set a non-interactive mode for `apt-get`
# to prevent it from asking for user input during the build.
ARG DEBIAN_FRONTEND=noninteractive

# Use ARGs to allow passing the host user's UID and GID at build time.
# We set default values to 1000 to ensure the build works even if no values are provided.
ARG UID=1000
ARG GID=1000

# Create a non-root user and group for security best practices, using the
# UID and GID passed from the host machine.
RUN groupadd -r dockergroup -g ${GID} && useradd -r -g dockergroup -m -d /home/dockeruser -u ${UID} dockeruser

# Install all the necessary packages for the HERO SDK and PULP software stack.
# It's a best practice to combine `apt-get update` and `apt-get install`
# in a single `RUN` command to ensure the packages are installed from the
# most recent repositories and to keep the image size down.
RUN apt-get update && apt-get install -y \
    zip \
    curl \
    flex \
    gawk \
    libtool-bin \
    libtool-doc \
    libncurses5-dev \
    bison \
    python3.6-dev \
    python3.6-venv \
    python3.6-doc \
    ninja-build \
    libssl-dev \
    git \
    python3-pip \
    texinfo \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    swig3.0 \
    libjpeg-dev \
    lsb-core \
    doxygen \
    python-sphinx \
    sox \
    graphicsmagick-libmagick-dev-compat \
    libsdl2-dev \
    libswitch-perl \
    libftdi1-dev \
    cmake \
    cowsay \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages using pip3.
RUN pip3 install artifactory twisted prettytable sqlalchemy pyelftools openpyxl xlsxwriter pyyaml numpy

# Switch to the new non-root user. All subsequent commands will be run as this user.
USER dockeruser

# Set the working directory to the user's home.
WORKDIR /home/dockeruser

# Define the HERO_INSTALL environment variable
ENV HERO_INSTALL=/home/dockeruser/hero/install

# Copy the contents of the build context (which is your `hero` directory)
# to the user's home directory inside the image. We use --chown to immediately
# set the ownership of the copied files to the UID and GID of the host user.
COPY --chown=${UID}:${GID} . /home/dockeruser/hero

# Set the default command for the container when it runs.
# In this case, we'll open a bash shell so you can interact with the files.
CMD ["/bin/bash"]
