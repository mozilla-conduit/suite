# Conduit Demo

Interactive demo of Mozilla's code-submission pipeline.

## Installation

### Prerequisites

1. You need to have the [docker](https://docs.docker.com/install/) and
   [docker-compose](https://docs.docker.com/compose/install/) installed.
1. An Auth0 developer account. See the
   [lando-ui README.md](https://github.com/mozilla-conduit/lando-ui/blob/master/README.md)
   for instructions on how to set that up.
1. Create an [AWS S3](https://aws.amazon.com/s3/) bucket. You will need to have:

  * The bucket name
  * AWS Access Key
  * AWS Secret Key

### Steps

* Pull the repository into a separate (e.g. `conduit`) directory.
* Go to the `conduit/demo` directory
* Create the `docker-compose.override.yml` file. Add the following
  configuration.  If in doubt, please refer to the relevant projects.

```
version: '2'
services:
  lando-ui:
    environment:
      - OIDC_DOMAIN=<your auth0 domain, e.g. account.auth0.com>
      - OIDC_CLIENT_ID=<your auth0 client id for lando-ui>
      - OIDC_CLIENT_SECRET=<your auth0 client secret for lando-ui>
      - LANDO_API_OIDC_IDENTIFIER=<your auth0 api identifiier for lando-api>
  lando-api:
    environment:
      - PATCH_BUCKET_NAME=<your aws patch bucket name>
      - AWS_ACCESS_KEY=<your aws access key>
      - AWS_SECRET_KEY=<your aws secret key>
      - OIDC_IDENTIFIER=<your auth0 api identifiier for lando-api>
      - OIDC_DOMAIN=<your auth0 domain>
      - LOCALDEV_MOCK_AUTH0_USER=<'default' (no quotes) or another option if you're familar with this>
      - TRANSPLANT_API_KEY=<fake transplant API key>
```
* Run `docker-compose build`

### First run
For the first run of the Lando API please instantiate the database:

```
$ docker-compose up --detach
$ docker exec -it demo_lando-api_1 lando-cli init
$ docker-compose down
```

## Using the demo repository

 1. `$ docker-compose run demo`. A shell will open.
 1. The preconfigured Mercurial repository is placed in
    `./version-control-tools/`.
 1. To point the repository to the `phabricator.test` we've changed the
    contents of the `.arcconfig` file. You can commit that change.
 1. Run `arc install-certificate` to authenticate yourself in the demo
    environment.  Choose one of the [Preconfigured Users](#preconfigured-users)
    (preferably the *conduit* one)
 1. Use as a normal local development repository.

*Note*: For the `git-cinnabar` usage we've cloned the same repository to the
`./vct-cinnabar/` directory. The modified Arcanist is also provided and aliased
as the `cinnabarc`.

## Accessing the websites provided by the demo

### Firefox configuration

You can either configure the existing Firefox to use our proxy, or run a
preconfigured Firefox.

**To configure your current browser**:

1. Open `Preferences -> Net Proxy -> Settings`
1. Choose the `Manual Proxy Configuration` radio button
1. Set the `Proxy HTTP Server` to `localhost`, and the `Port` to `1080`.

**To run Firefox with an empty profile**:

1. Please set the environment variable `FIREFOX_CMD` to `/path/to/firefox` if
   your system does not recognize the `firefox` command.
1. In a new terminal, run `firefox-proxy`, or
   `firefox-proxy $(docker-machine ip)` if you are using `docker-machine`.
1. A new browser with an empty profile will open.

### Websites provided by the demo

 * Phabricator - http://phabricator.test
 * Lando - http://lando-ui.test
 * Lando API - http://lando-api.test/ui via Swagger UI.
 * Bugzilla - http://bmo.test

## Running apps from local repositories

Each related application cluster also has its own corresponding Docker Compose
configuration file.

It is useful for doing development work as it allows you to specify which
application cluster should instead run from a local repository.

### Preparing the environment

To allow the override compose files to work properly, you need to have
your repository directory structure set up correctly. Please clone the
repositories you wish to use locally to the `conduit` directory.

```
$ git clone git@github.com:mozilla-conduit/arcanist.git
$ git clone git@github.com:mozilla-bteam/bmo.git
$ git clone git@github.com:mozilla-conduit/lando-api.git
$ git clone git@github.com:mozilla-conduit/lando-ui.git
$ git clone git@github.com:mozilla-services/phabricator-extensions.git
```

Phabricator-extensions build process requires existence of the `phabext.json`
file. Please add it with the command:

`$ echo "{}" > phabricator-extensions/phabext.json`

If you'd install all of the above projects your directory structure would
look as below:

```
conduit
├── arcanist/
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
    └── Dockerfile
```

### Usage

You can use each app from its local repository. For example, to run a
Phabricator extension code from a local repository instead of the code already
in the `mozilla/phabext` Docker image:

```
$ docker-compose -f docker-compose.yml -f docker-compose.phabricator.yml build
$ docker-compose -f docker-compose.yml -f docker-compose.phabricator.yml run demo
```

You can also use multiple apps from local repositories. I.e. to work on both
Phabricator and Bugzilla:

```
$ docker-compose -f docker-compose.yml -f docker-compose.phabricator.yml -f docker-compose.bmo.yml build
docker-compose -f docker-compose.yml -f docker-compose.phabricator.yml -f docker-compose.bmo.yml run demo
```

Note you normally must have `-f docker-compose.yml` included as the first one.

## Preconfigured users:

For performing administration tasks in Phabricator, first log out of
Phabricator and then go to http://phabricator.test/?admin=1

`user:admin`, `password:password123456789!`

For logging in as a normal test user, you will need to use BMO for
auth-delegation. Log out in Phabricator and then click on 'Log In or
Register'. You will be redirected to BMOs login page.

`user:conduit@mozilla.bugs`, `password:password123456789!`

After login, if it complains that you do not have MFA enabled on your
BMO account, click on the 'preferences' link that will allow you to configure
TOTP and then you should be able to login to Phabricator.

For performing administrative tasks on BMO, you will need to log out of BMO
and then login on http://bmo.test/login with the following credentials.

`user:admin@mozilla.bugs`, `password:Te6Oovohch`




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
 1. `$ gzip demo.sql`
 1. `$ cp demo.sql.gz docker/phabricator/demo.sql.gz`
 1. Submit a [PR](https://github.com/mozilla-conduit/demo/pulls) with
    the changes.
