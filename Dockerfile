FROM ocaml/opam:debian-12-ocaml-4.14 AS build

USER root

RUN apt-get update -qq && apt-get install --no-install-recommends -y -qq \
        build-essential \
        ca-certificates \
        libgmp-dev \
        make \
        python3 \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:0.12.23 /uv /uvx /bin/

ENV UV_PROJECT_ENVIRONMENT=/opt/venv
COPY pyproject.toml uv.lock /tmp/project/
WORKDIR /tmp/project
RUN uv sync --locked --no-dev --no-install-project --no-cache
ENV PATH="/opt/venv/bin:${PATH}"

ARG ROCQ_VER=9.2.0

ADD https://github.com/rocq-prover/rocq/archive/refs/tags/V${ROCQ_VER}.tar.gz rocq.tar.gz
RUN mkdir /rocq && tar zxf rocq.tar.gz -C /rocq --strip-components=1 \
    && chown -R opam:opam /rocq

USER opam
WORKDIR /rocq

RUN eval "$(opam env)" && opam install --yes dune.3.23.1 ocamlfind zarith

FROM build AS refman

RUN LANG=C.UTF-8 LC_ALL=C.UTF-8 eval "$(opam env)" && make refman-html

FROM refman AS docset

COPY coq_parser.py /store/

RUN find _build/default/doc/refman-html -type f -exec chmod u+w {} + \
    && LANG=C.UTF-8 LC_ALL=C.UTF-8 PYTHONPATH=/store/ doc2dash -n Rocq -i ./ide/rocqide/coq.png \
         --parser coq_parser.RocqSphinxParser _build/default/doc/refman-html
