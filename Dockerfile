#
# Dockerfile for drpyS
#

FROM node:20-alpine AS builder

RUN set -ex \
  && apk add --update --no-cache \
     git \
     python3-dev \
     py3-pip \
     py3-wheel

WORKDIR /app

RUN set -ex \
  && git clone --depth 1 -q https://github.com/hjdhnx/drpy-node.git . \
  && yarn && yarn add puppeteer \
  && sed 's|^VIRTUAL_ENV[[:space:]]*=[[:space:]]*$|VIRTUAL_ENV=/app/.venv|' .env.development > .env \
  && rm -f .env.development \
  && echo '{"ali_token":"","ali_refresh_token":"","quark_cookie":"","uc_cookie":"","bili_cookie":"","thread":"10","enable_dr2":"1","enable_py":"2"}' > config/env.json

RUN python3 -m venv .venv
ENV PATH="/app/.venv/bin":$PATH
RUN pip3 install -r spider/py/base/requirements.txt

FROM node:20-alpine

COPY --from=builder /app /app

RUN set -ex \
  && apk add --update --no-cache \
     python3 tini \
  && rm -rf /tmp/* /var/cache/apk/*

ENV PATH="/app/.venv/bin":$PATH

WORKDIR /app

EXPOSE 5757

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "index.js"]
