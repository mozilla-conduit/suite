# Conduit Suite

This repository contains Docker configuration files to start up a local
installation of most of the parts of Mozilla's code-review-and-landing
system, collectively known as "Conduit".  This includes

* BMO, Mozilla's Bugzilla fork
* Phabricator, including extensions and patches
* Lando, both API and UI
* Transplant, the service that lands commits
* A Mercurial server
* A container ("local-dev") with various command-line tools including MozPhab

The suite allows only some services to be started up, if the whole
system is not needed.  It also provides the option of using both local
clones and hosted images, so you need only have the code checked out
for the service(s) you need to modify.

This suite can be used to demo Conduit services and to aid in
development.  This repository, however, should not be viewed as a
substitute for self-contained tests in individual repositories.

## Installation

### Prerequisites

1. You need to have [docker](https://docs.docker.com/install/) and
   [docker-compose](https://docs.docker.com/compose/install/) installed.
1. For Lando, an Auth0 developer account. See the
   [lando-ui README.md](https://github.com/mozilla-conduit/lando-ui/blob/master/README.md)
   for instructions on how to set that up.
1. Also for Lando/Transplant, an [AWS S3](https://aws.amazon.com/s3/)
   bucket, which requires

  * The bucket name
  * AWS Access Key
  * AWS Secret Key

### Steps

* Pull the repository into a separate (e.g. `conduit`) directory.
* Go to the `conduit/suite` directory
* Depending on what services you plan to run, you may need to create a
  `docker-compose.override.yml` file. At the moment, this is only
  required for Lando and Transplant. If in doubt, please refer to the
  relevant projects.  Here is a sample file:

```
version: '3.4'
services:
  lando-ui:
    environment:
      OIDC_DOMAIN: <your auth0 domain, e.g. account.auth0.com>
      OIDC_CLIENT_ID: <your auth0 client id for lando-ui>
      OIDC_CLIENT_SECRET: <your auth0 client secret for lando-ui>
      LANDO_API_OIDC_DOMAIN: <your auth0 domain, e.g. example.us.auth0.com>
      LANDO_API_OIDC_IDENTIFIER: <your auth0 api identifiier for lando-api>

  lando-api:
    environment:
      PATCH_BUCKET_NAME: <your aws patch bucket name>
      AWS_ACCESS_KEY: <your aws access key>
      AWS_SECRET_KEY: <your aws secret key>
      # Optional: 'http://lando-api.test' by default
      OIDC_DOMAIN: <your auth0 domain>
      OIDC_CLIENT_ID: <your auth0 client id for lando-ui>
      OIDC_CLIENT_SECRET: <your auth0 client secret for lando-ui>
      LANDO_API_OIDC_IDENTIFIER: http://lando-api.test
      LANDO_API_OIDC_DOMAIN: <your auth0 domain, e.g. example.us.auth0.com>
      OIDC_IDENTIFIER: <your auth0 api identifiier for lando-api>
      # Optional: 'inject_valid' by default
      LOCALDEV_MOCK_AUTH0_USER: <'default' | 'inject_valid' | 'inject_invalid'>
      LOCALDEV_MOCK_TRANSPLANT_SUBMIT: <'succeed' | 'fail'>

  autoland.transplant-init:
    environment: &transplant_secret
      LANDO_BUCKET: <your aws patch bucket name>
      LANDO_AWS_KEY: <your aws access key>
      LANDO_AWS_SECRET: <your aws secret key>

  autoland.transplant-api:
    environment: *transplant_secret

  autoland.transplant-daemon:
    environment: *transplant_secret
```

* Run `docker-compose build`

### First run of Lando

If you are running Lando, you will need to first initialize the database:

```shell
docker-compose exec lando-api lando-cli db upgrade
```

## Using the local-dev service

The "local-dev" container includes command-line tools used to interact
with Conduit services.

To set up the container run `docker-compose run local-dev`.
You will be placed inside of a repository cloned from http://hg.test. You can
use it as a normal local development repository.

**Note**: A `git-cinnabar` version of the same repository is located at
`~/test-repo-cinnabar/`. The forked version of Arcanist is also
provided and aliased as the `cinnabarc`.

## Accessing the websites provided by the suite

### Firefox configuration

You can either configure an existing Firefox instance to use our
proxy, or run a preconfigured Firefox.

**To configure your current browser**:

1. Open `Options -> Network Proxy -> Settings`
1. Choose the `Manual Proxy Configuration` radio button
1. Set `HTTP Proxy` to `localhost` and `Port` to `1080`.

**To run Firefox with an empty profile**:

1. Please set the environment variable `FIREFOX_CMD` to `/path/to/firefox` if
   your system does not recognize the `firefox` command.
1. In a new terminal, run `firefox-proxy`, or
   `firefox-proxy $(docker-machine ip)` if you are using `docker-machine`.
1. A new browser with an empty profile will open.

### Websites provided by the suite

 * Phabricator - http://phabricator.test
 * Lando - http://lando-ui.test
 * Lando API - http://lando-api.test/ui via Swagger UI.
 * Bugzilla - http://bmo.test
 * Mercurial - http://hg.test

## Running apps from local clone

Each Conduit application also has its own corresponding Docker Compose
configuration file.

This is useful for doing development work as, it allows you to specify which
application should run from a local clone instead of from a hosted image.

### Preparing the environment

To allow the override compose files to work properly, you need to have
your repository directory structure set up correctly. Please clone the
repositories you wish to use locally to the `conduit` directory.

```shell
git clone git@github.com:mozilla-conduit/arcanist.git
git clone git@github.com:mozilla-bteam/bmo.git
git clone git@github.com:mozilla-conduit/lando-api.git
git clone git@github.com:mozilla-conduit/lando-ui.git
git clone git@github.com:mozilla-conduit/phabricator.git
git clone git@github.com:mozilla-conduit/phabricator-emails.git
git clone git@github.com:mozilla-conduit/review.git
```

If you've installed all of the above projects, your directory structure
would look as below:

```shell
$ tree
conduit
├── arcanist/
├── bmo/
├── suite/
├── lando-api/
├── lando-ui/
├── phabricator/
├── phabricator-emails/
└── review/

```

### Usage

You can use each app from its local repository. For example, to run
the phabricator code from a local repository instead of the
`mozilla/phabext` image,

```shell
# Build the containers
$ docker-compose \
  -f docker-compose.yml \
  -f docker-compose.phabricator.yml \
  -f docker-compose.override.yml \
  build
# Start the containers
$ docker-compose \
  -f docker-compose.yml \
  -f docker-compose.phabricator.yml \
  -f docker-compose.override.yml \
  up -d
```

You can also use multiple apps from local repositories. For example,
to work on both Phabricator and Bugzilla,

```shell
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.phabricator.yml \
  -f docker-compose.bmo.yml \
  -f docker-compose.override.yml \
  up --build -d
```

And for example to work on lando-ui and lando-api,

```shell
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.lando-api.yml \
  -f docker-compose.lando-ui.yml \
  -f docker-compose.override.yml \
  up --build -d
```

Note that normally you must have `-f docker-compose.yml` as the first
option and `-f docker-compose.override.yml` as the last one.

To work on a local version of the Arcanist fork, load the
`docker-compose.cinnabarc.yml` configuration. This will modify the
`arc` command in the `local-dev` service. Similarly, to load a local version 
of the ARC wrapper "review" , load the `docker-compose.review.yml`. 

If you don't want to spin up all configured containers, you can
specify the ones you'd like to work on. The command below runs
`phabricator.test`, `phabricator`, `phabdb`, `lando-api.test`,
`lando-api` and `lando-api.db` to allow the verification of the
integration between Phabricator and Lando API:

`docker-compose up phabricator.test lando-api.test`

## Preconfigured users:

For performing administration tasks in Phabricator, first log out of
Phabricator and then go to http://phabricator.test/auth/start/?admin and log 
in with

`user:admin`, `password:password123456789!`

To log in as a normal test user, you will need to use BMO for
auth delegation. Log out of Phabricator and then click on 'Log In or
Register'. You will be redirected to BMO's login page.

`user:conduit@mozilla.bugs`, `password:password123456789!`

We also have a `ConduitReviewer` account that can be opened in a second private
browser window for performing the other half of the review dance.  On the BMO 
login page enter:

`user:conduit-reviewer@mozilla.bugs`, `password:password123456789!`

After login, if it complains that you do not have MFA enabled on your
BMO account, click on the 'Preferences' link that will allow you to
configure TOTP and then you should be able to login to Phabricator.

For performing administrative tasks on BMO, you will need to log out
of BMO and then log in at http://bmo.test/login with the following
credentials:

`user:admin@mozilla.bugs`, `password:password012!`

## Updating the preloaded Phabricator database

As noted in [this Phabricator ticket](https://secure.phabricator.com/T5310),
the only way we can set up an out-of-the-box Phabricator is to preload
the application database with the settings we want.

To update the preloaded database with new settings:

 1. **Important:** Run `docker-compose down` and
    `docker volume rm suite_phabricator-mysql-db` to ensure you have a
    fresh DB!
 1. Start the application with `docker-compose up` and log in with the
    appropriate user ("admin" to update global settings, "phab-bot" for
    things like API keys).
 1. Change the desired setting.
 1. Run `docker-compose run phabricator dump > demo.sql` to dump the
    database.
 1. Edit `demo.sql` and delete the extra shell output at the beginning and at
    the end of the file.
 1. `$ gzip demo.sql`
 1. `$ mv demo.sql.gz docker/phabricator/demo.sql.gz`
 1. Submit a [PR](https://github.com/mozilla-conduit/suite/pulls) with
    the changes.

## Clone the test repository

The `local-dev` service uses repositories cloned from http://hg.test/.
You will need to re-clone them every time Mercurial server images are
created.  There is a bash script which will remove the existing
directories and clone the repositories using `hg` and `git-cinnabar`:

`# ./clone_repositories.sh`

## Successful landing step by step

Start the suite:

```shell
docker-compose up -d
docker-compose exec lando-api lando-cli db upgrade
```

Create a diff:

```shell
$ docker-compose run local-dev
# ./clone-repositories.sh
# cd test-repo
# echo test >> README
# hg commit -m "test info added"
# moz-phab install-certificate
# moz-phab submit -b 1
```

Log in to http://lando-ui.test.

Navigate to http://lando-ui.test/revisions/D2.

Confirm the warning and click on the `Land` button.

Reload the page. Observe the landing confirmation.

Check if the commit is present in the http://hg.test/.
