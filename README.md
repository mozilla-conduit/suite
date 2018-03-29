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
    Please set the environment variable `FIREFOX_CMD=path/to/firefox` if your
    system does not recognize the `firefox` command.
    A new browser with an empty profile will open.  If you don't want to use
    the script, configure your browser to use the demo SOCKS proxy, available
    on port 1080 of your Docker host's IP.
 1. Visit `http://phabricator.test` in the new browser window and log in
    using BMO auth-delegation to work with your new review.
 1. Visit `http://lando-ui.test` For full Lando experience.
 1. Visit `http://lando-api.test` to use Lando API via Swagger UI.

## Running apps from local repositories

Each related application cluster also has its own corresponding Docker Compose configuration file.
There are useful for doing development work as it allows you you to specify which application cluster
should instead run from a local repository.

For example, to run a Phabricator extension code from a local repository instead of the code already
in the `mozilla/phabext` Docker image:

```
$ docker-compose -f docker-compose.yml -f docker-compose.phabricator.yml build
$ docker-compose -f docker-compose.yml -f docker-compose.phabricator.yml run demo
```

Note you normally must have `-f docker-compose.yml` included as the first one. Also to allow the override
compose files to work properly, you need to have your repository directory structure set up correctly.

```
conduit
├── bmo/
│   ├── Dockerfile
├── demo/
│   ├── docker/
│   ├── docker-compose.bmo.yml
│   ├── docker-compose.lando-api.yml
│   ├── docker-compose.lando-ui.yml
│   ├── docker-compose.phabricator.yml
│   ├── docker-compose.yml
├── lando-api/
│   └── docker/
│       └── Dockerfile-dev
├── lando-ui/
│   └── docker/
│       └── Dockerfile-dev
└── phabricator-extensions/
    └── Dockerfile-test
```

## Preconfigured users:

For performing administration tasks in Phabricator, first log out of Phabricator and then go to:

`http://phabricator.test/?admin=1`

`user:admin`, `password:password123456789!`

For logging in as a normal test user, you will need to use BMO for auth-delegation. Log out in Phabricator and then click on 'Log In or Register'. You will be redirected to BMOs login page.

`user:conduit@mozilla.bugs`, `password:password123456789!`

After login, if it complains that you do not have MFA enabled on your BMO account, click on the 'preferences' link that will allow you to configure TOTP and then you should be able to login to Phabricator.

For performing administrative tasks on BMO, you will need to log out of BMO and then login with the following credentials:

`http://bmo.test/login`

`user:admin@mozilla.bugs`, `password:Te6Oovohch`

## Local configuration

To configure Lando API create `docker-compose.override.yml` file with
content as below
```yaml
version: '2'
services:
  lando-api:
    environment:
      # To set the API key, login as a user on http://phabricator.test/,
      # create a new Conduit API token and add it here.
      - PHABRICATOR_UNPRIVILEGED_API_KEY=api-set-the-hashtag
      - TRANSPLANT_API_KEY=some-api-key
      - PATCH_BUCKET_NAME=your.personal.bucket.name
      - AWS_ACCESS_KEY=YOUR_ACCESS_KEY
      - AWS_SECRET_KEY=YOUR_SECRET_KEY
```

### First run
For the first run of the Lando API please instantiate the database by running
`docker exec -it demo_lando-api_1 lando-cli init`.

## Updating the preloaded demo

As noted in [this Phabricator ticket](https://secure.phabricator.com/T5310),
the only way we can set up an out-of-the-box demo of Phabricator is to preload
the application database with the settings we want.

To update the preloaded database with new settings:

 1. **Important:** Run `docker-compose down` and
    `docker volume rm demo_phabricator-mysql-db` to ensure you have a
    fresh DB!
 1. Start the application with `docker-compose up` and log in with the
    appropriate user ("admin" to update global settings, "phab-bot" for
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

