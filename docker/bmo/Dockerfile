# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

FROM mozillabteam/bmo-ci
MAINTAINER David Lawrence <dkl@mozilla.com>

ENV CONDUIT_LOGIN conduit@mozilla.bugs
ENV CONDUIT_PASSWORD password
ENV CONDUIT_API_KEY zQ5TSBzq7tTZMtKYq9K1ZqJMjifKx3cPL7pIGk9Q

# Supervisor setup
COPY conf/supervisord.conf /etc/supervisord.conf
RUN chmod 700 /etc/supervisord.conf

# Apache configuration
COPY conf/bugzilla.conf /etc/httpd/conf.d/bugzilla.conf

# Copy setup scripts
COPY scripts/* /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

# Apache fixes
RUN sed -e "s?^User apache?User $BUGZILLA_USER?" --in-place /etc/httpd/conf/httpd.conf
RUN sed -e "s?^Group apache?Group $BUGZILLA_USER?" --in-place /etc/httpd/conf/httpd.conf

# Development environment setup
RUN rm -rf $BUGZILLA_ROOT \
    && git clone $GITHUB_BASE_GIT -b $GITHUB_BASE_BRANCH $BUGZILLA_ROOT \
    && ln -sf $BUGZILLA_LIB $BUGZILLA_ROOT/local
COPY conf/checksetup_answers.txt $BUGZILLA_ROOT/checksetup_answers.txt
RUN bugzilla_config.sh

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
