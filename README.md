# Conduit Suite

This repository contains Docker configuration files to start up a local
installation of most of the parts of Mozilla's code-review-and-landing
system, collectively known as "Conduit". This includes

- BMO, Mozilla's Bugzilla fork
- Phabricator, including extensions and patches
- Lando
- Phabricator Emails service
- Git-Hg-Sync service
- A Mercurial server
- A Git Server
- A container ("local-dev") with various command-line tools including moz-phab

## Installation

### Prerequisites

1. You need to have [docker](https://docs.docker.com/install/) installed.
2. For Lando, an Auth0 developer account. See the
   [lando README.md](https://github.com/mozilla-conduit/lando/blob/main/README.md)
   for instructions on how to set that up.

### Cloning the Repositories

Your directory structure must be set up correctly with clones of the various
services that make up the suite.

```shell
mkdir conduit && cd conduit
git clone git@github.com:mozilla-conduit/suite.git
git clone git@github.com:mozilla-bteam/bmo.git
git clone git@github.com:mozilla-conduit/arcanist.git
git clone git@github.com:mozilla-conduit/cgit-docker.git
git clone git@github.com:mozilla-conduit/lando.git
git clone git@github.com:mozilla-conduit/phabricator-emails.git
git clone git@github.com:mozilla-conduit/phabricator.git
git clone git@github.com:mozilla-conduit/review.git # moz-phab
git clone https://github.com/mozilla-conduit/git-hg-sync
```

If you've installed all of the above projects, your directory structure
would look as below:

```shell
conduit
├── arcanist/
├── bmo/
├── cgit-docker/
├── git-hg-sync/
├── lando/
├── phabricator-emails/
├── phabricator/
├── review/
└── suite/
```

### Prepare the Environment

To log into Lando you need to configure `lando/.env` with the `OIDC` settings, as per your Auth0 personal
instance:

```
OIDC_DOMAIN=...
OIDC_RP_CLIENT_ID=...
OIDC_RP_CLIENT_SECRET=...
```

## Usage

The `./suite` script can be used as a wrapper of the system `docker compose`,
and adds the necessary command line arguments as needed.

By default, all images are built locally from your clones, and are
started by docker-compose:

```shell
./suite up --build
```

If you don't want to spin up all configured containers, you can
specify the ones you'd like to work on. The command below runs
`phabricator.test`, which spins up only Phabricator, Lando, and
their dependencies.

```shell
./suite up phabricator.test lando.test
```

### Compose overrides

If temporary local changes to the compose stack are needed, overrides can be
added to the `docker-compose.override.yml` file. This file is listed in the
`.gitignore` file, and will therefore not be committed.

The `./suite` script transparently apply the overrides if the file is present.

## Accessing the websites provided by the suite

### Firefox configuration

You can either configure an existing Firefox instance to use our
proxy, or run a preconfigured Firefox.

**To configure your current browser**:

1. Open `Options -> Network Proxy -> Settings`
2. Choose the `Manual Proxy Configuration` radio button
3. Set `HTTP Proxy` to `localhost` and `Port` to `1080`.

**To run Firefox with an empty profile**:

1. Please set the environment variable `FIREFOX_CMD` to `/path/to/firefox` if
   your system does not recognize the `firefox` command.
2. In a new terminal, run `firefox-proxy`, or
   `firefox-proxy $(docker-machine ip)` if you are using `docker-machine`.
3. A new browser with an empty profile will open.

### Websites provided by the suite

- Bugzilla - http://bmo.test
- Phabricator - http://phabricator.test
- Lando - http://lando.test
- Mercurial - http://hg.test
- Git - http://git.test

### Preconfigured users:

To log in as a normal test user, you will need to use BMO for
auth delegation. Log out of Phabricator and then click on 'Log In or
Register'. You will be redirected to BMO's login page.

`user:conduit@mozilla.bugs`, `password:password123456789!`

We also have a `ConduitReviewer` account that can be opened in a second private
browser window for performing the other half of the review dance. On the BMO
login page enter:

`user:conduit-reviewer@mozilla.bugs`, `password:password123456789!`

After login, if it complains that you do not have MFA enabled on your
BMO account, click on the 'Preferences' link that will allow you to
configure TOTP and then you should be able to login to Phabricator.

For performing administrative tasks on BMO, you will need to log out
of BMO and then log in at http://bmo.test/login with the following
credentials:

`user:admin@mozilla.bugs`, `password:password012!`

For performing administration tasks in Phabricator, first log out of
Phabricator and then go to http://phabricator.test/auth/start/?admin and log
in with

`user:admin`, `password:password123456789!`

A local Git server is also available at http://git.test. The `conduit` user can
log in with the credentials above. For administrative tasks, the account details are as follows:

`user:git-admin`, `password:password123456789!`

A local RabbitMQ server is running at pulse.test:5672. The administrative
interface can be found at http://pulse.test:15672. The credentials are
this service are

`user:guest`, `password:guest`

## Using the local-dev service

The "local-dev" container includes command-line tools used to interact
with Conduit services.

To set up the container run `./suite run --rm local-dev`.
You will be placed inside of a repository cloned from http://hg.test. You can
use it as a normal local development repository.

**Note**: A `git-cinnabar` version of the same repository is located at
`~/test-repo-cinnabar/`.

## Using the git_hg_sync service

While a Pulse exchange is created by default, nothing listens to it. It
is possible to start a `git_hg_sync` container to test the SCM sync
logic.

git_hg_sync will create a `unified-cinnabar` git repository in
`git.test`. It contains multiple branches, each one cloned from the Mercurial
repositories using git-cinnabar. The branches are configured by default in Phabricator
and Lando (via the `create_environment_repos` command).

When the repository exists, the `local-dev` container will clone it in
`/repos/unified-cinnabar`. All branches will be available. Crucially, the
`.arcconfig` on each branch will need to be updated to point to the git
repository.  To do so, the callsign of the repo needs to be updated by adding
`GIT` at the end. Otherwise, revisions will be submitted against the original Hg
repo.

When the git_hg_sync service is running, any revision landed to the
`unified-cinnabar` repository, on any of the default branches, will be synced to
the associated Mercurial repository.

## Updating the preloaded Phabricator database

As noted in [this Phabricator ticket](https://secure.phabricator.com/T5310),
the only way we can set up an out-of-the-box Phabricator is to preload
the application database with the settings we want.

To update the preloaded database with new settings:

1.  **Important:** Run `./suite down` and
    `docker volume rm suite_phabricator-mysql-db` to ensure you have a
    fresh DB!
2.  Start the application with `./suite up` and log in with the
    appropriate user ("admin" to update global settings, "phab-bot" for
    things like API keys).
3.  Change the desired setting.
4.  Run `./suite run phabricator dump > demo.sql` to dump the
    database.
5.  Edit `demo.sql` and delete the extra shell output at the beginning of the file.
6.  `$ gzip demo.sql`
7.  `$ mv demo.sql.gz docker/phabricator/demo.sql.gz`
8.  Submit a [PR](https://github.com/mozilla-conduit/suite/pulls) with
    the changes.

## Clone the test repository

The `local-dev` service uses repositories cloned from http://hg.test/.
You will need to re-clone them every time Mercurial server images are
created. There is a bash script that will remove the existing
directories and clone the repositories using `hg` and `git-cinnabar`:

```shell
./clone_repositories.sh
```

## Successful landing step by step

Start the suite:

```shell
./suite up -d
```

Create a diff:

```shell
./suite run --rm local-dev

cd repos
cd test-repo
echo test >> README
hg commit -m "test info added"
moz-phab install-certificate
moz-phab submit -b 1
```

- Log in to http://lando.test.
- Navigate to http://lando.test/revisions/D2.
- Confirm the warning and click on the `Land` button.
- Reload the page. Observe the landing confirmation.
- Check if the commit is present in the http://hg.test/.

