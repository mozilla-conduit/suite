# !/bin/sh

# Run docker-compose with local repos, excluding Bugzilla.
# The following repos should be cloned in the parent directory:

# https://github.com/mozilla-conduit/conduit-autoland-hg
# https://github.com/mozilla-conduit/lando-api
# https://github.com/mozilla-conduit/lando-ui
# https://github.com/mozilla-conduit/phabricator
# https://github.com/mozilla-conduit/review

docker-compose \
-f docker-compose.yml \
-f docker-compose.review.yml \
-f docker-compose.lando-api.yml \
-f docker-compose.lando-ui.yml \
-f docker-compose.autolandhg.yml \
-f docker-compose.phabricator.yml \
-f docker-compose.override.yml \
up --build -d
