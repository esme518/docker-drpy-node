#
# Dockerfile for drpyS
#

FROM cgr.dev/chainguard/wolfi-base:latest AS builder

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN set -ex \
  && apk add --update --no-cache \
     build-base \
     git \
     nodejs-20 \
     npm \
     yarn \
     python-3.10-dev \
     py3.10-pip

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

FROM cgr.dev/chainguard/wolfi-base:latest

COPY --from=builder /app /app
ENV LANG=C.UTF-8
ENV PYTHONUNBUFFERED=1

RUN set -ex \
  && apk add --update --no-cache \
     nodejs-20 python-3.10 tini \
  && rm -rf /tmp/* /var/cache/apk/*

ENV PATH="/app/.venv/bin":$PATH

WORKDIR /app

EXPOSE 5757

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "index.js"]
