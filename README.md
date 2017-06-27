# Conduit Demo

Interactive demo of Mozilla's code-submission pipeline.

## Prerequisites

 * `docker` (on OS X you will want `docker-machine`, too)
 * `docker-compose`
 * Firefox, or some other way to connect your browser to a SOCKS proxy.

## Running the demo

 1. Run `docker-compose run demo`.
 1. In the shell opened by `docker-compose run demo`, create a repo and
    use `arc diff` to submit a review.
 1. In a new terminal, run `firefox-proxy`, or
    `firefox-proxy $(docker-machine ip)` if you are using `docker-machine`.
    A new browser with an empty profile will open.  If you don't want to use
    the script, configure your browser to use the demo SOCKS proxy, available
    on port 1080 of your Docker host's IP.
 1. Visit `http://phabricator.test` in the new browser window and log in
    with `user:phab` and `password:phab` to work with your new review.

Preconfigured users:
 * `user:phab`, `password:phab`
 * `user:admin`, `password:admin`

## Updating the preloaded demo

As noted in [this Phabricator ticket](https://secure.phabricator.com/T5310),
the only way we can set up an out-of-the-box demo of Phabricator is to preload
the application database with the settings we want.

To update the preloaded database with new settings:

 1. **Important:** Run `docker-compose down` and
    `docker volume rm demo_phabricator-mysql-db` to ensure you have a
    fresh DB!
 1. Start the application with `docker-compose up` and log in with the
    appropriate user ("admin" to update global settings, "phab" for
    things like API keys).
 1. Change the desired setting.
 1. Run `docker-compose run phabricator dump > demo.sql` to dump the
    database.
 1. Edit `demo.sql` and delete the extra shell output at the beginning and at
    the end of the file.
 1. `gzip demo.sql`
 1. `cp demo.sql.gz docker/phabricator/demo.sql.gz`
 1. Submit a [PR](https://github.com/mozilla-conduit/conduit-demo/pulls) with
    the changes.

