# This Dockerfile is part of the memote meta study.
# Copyright (C) 2019, Novo Nordisk Foundation Center for Biosustainability,
#     Technical University of Denmark
#
# This Dockerfile is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

ARG TAG=3.6.1

FROM rocker/verse:${TAG}

WORKDIR /opt

RUN set -eux \
    && apt-get update \
    && apt-get install --yes \
        libudunits2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/install_requirements.R ./

RUN Rscript install_requirements.R

# Since `tlmgr path add` returns with an error code, we do not want to interrupt
# the pipeline and the docker build process. Thus we avoid `set -e`.
RUN set -ux \
    && tlmgr install \
        colortbl \
        environ \
        makecell \
        multirow \
        placeins \
        tabu \
        threeparttable \
        threeparttablex \
        trimspaces \
        ulem \
        varwidth \
        wrapfig \
        xcolor \
    # Ensure that the pipeline finishes with a non-error return code.
    && tlmgr path add || true

WORKDIR /home/rstudio

USER rstudio

