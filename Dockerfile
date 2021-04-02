FROM debian:bullseye-slim

ARG CARBON_ROOT_DIR

## Installing NPM
RUN apt-get update && apt-get install -y curl git
RUN curl -fsSL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install -y nodejs

RUN npm i -g carbon-now-cli@1.4.0
##

### Installing CHROME (needed by carbon-now-cli
# Add a user for running applications.
RUN useradd carbon
RUN mkdir -p ${CARBON_ROOT_DIR} && chown carbon:carbon ${CARBON_ROOT_DIR}

# Install x11vnc.
RUN apt-get install -y x11vnc

# Install xvfb.
RUN apt-get install -y xvfb

# Install fluxbox.
RUN apt-get install -y fluxbox

# Install wget.
RUN apt-get install -y wget

# Install wmctrl.
RUN apt-get install -y wmctrl

# Set the Chrome repo.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Install Chrome.
RUN apt-get update && apt-get -y install google-chrome-stable
###

WORKDIR ${CARBON_ROOT_DIR}