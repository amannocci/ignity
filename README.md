# Ignity

*Dead simple process supervision for containers based on s6.*  
*Inspired by s6-overlay*
* [Source](https://github.com/amannocci/ignity)
* [Issues](https://github.com/amannocci/ignity/issues)
* [Contact](mailto:adrien.mannocci@gmail.com)

## Prerequisites
* [Docker](https://docs.docker.com/get-docker/) for development.

## Features
* Low memory overhead
* Simple lifecycle management
* Fast startup
* Reliable supervision
* Allow high inheritance

## Develop

### Setup
The following steps will ensure your project is cloned properly.
1. `git clone https://github.com/amannocci/ignity`
2. `cd ignity && ./scripts/workflow.sh setup`

### Test
* To test you have to use the workflow script.

```bash
./scripts/workflow.sh test
```

* It will test project code with the current environment.

### Package
* To package you have to use the workflow script.

```bash
./scripts/workflow.sh package
```

* It will create a tar archive containing ignity.

## Usage

### How it works
* We use `s6` as supervision suite.

### Available configuration parameters
| Parameter | Description | Value (Current) |
| --------- | ----------- | --------------- |
| `IGNITY_CMD_WAIT_FOR_SERVICES_MAXTIME` | The maximum time (in milliseconds) the services could take to bring up before proceding to CMD executing | 5000 |
| `IGNITY_CMD_WAIT_FOR_SERVICES` | In order to proceed executing CMD overlay will wait until services are up | 0 |
| `IGNITY_KILL_FINISH_MAXTIME` | The maximum time (in milliseconds) a script in `/etc/ignity/finalize` could take before sending a `KILL` signal to it | 5000 |
| `IGNITY_KILL_GRACETIME` | How long (in milliseconds) `ignity` should wait to reap zombies before sending a `KILL` signal | 3000 |
| `IGNITY_SERVICES_GRACETIME` | How long (in milliseconds) `ignity` should wait services down before sending a down signal | 5000 |
| `USER` | User name to map with uid and gid | root |
| `USERMAP_GID` | User gid to map on files | 0 |
| `USERMAP_UID` | User uid to map on files | 0 |

### How to use ignity as `ENTRYPOINT`

* By default, `ignity` isn't set as entrypoint.
* If you want to use it to handle services and all specifics stuff you have to explicitly define it as entrypoint.

```bash
ENTRYPOINT [ "/init" ]
```

### How to load env files

* Sometimes it's interesting to load env files to define default variables.
* You can simply put any env files in `/etc/ignity/envs` and they will be loaded during runtime in order.
* They will be overrided by container environments variables.

### How to supervise a service

* Creating a supervised service cannot be easier
* Just create a service directory with the name of your service into `/etc/ignity/services`
* Put a `run` file into it, this is the file in which you'll put your long-lived process execution
* You're done! If you want to know more about s6 supervision of servicedirs take a look to [`servicedir`](https://skarnet.org/software/s6/servicedir.html) documentation.

### How to run a container with non root user
* To run a container with a non root user, you have to define files and directories permissions in `perms` and then define the following in the Dockerfile

```bash
ENV \
  USERMAP_UID="1000" \
  USERMAP_GID="1000" \
  USER="exploit"
RUN stage2-perms
USER ${USERMAP_UID}:${USERMAP_GID}
```

* This will correct permissions at build time instead of runtime and will let the container start properly with a non root user.

### How to fix ownership & permissions

* Sometimes it's interesting to fix ownership & permissions before proceeding because, for example, you have mounted/mapped a host folder inside your container.
* Ignity provides a way to tackle this issue using files in `/etc/ignity/perms`.
* The pattern format followed by fix-perms files:

```text
path recurse account fmode dmode
> /var/lib/mysql 1000:1000 0600 0700
```

* `path`: File or dir path.
* `account`: Target account `uid:gid`.
* `fmode`: Target file mode. For example, `0644`.
* `dmode`: Target dir/folder mode. For example, `0755`.

* You can use variables `{{USERMAP_UID}}` and `{{USERMAP_GID}}` in those files.  
* They will be replaced at runtime or build time based on case. 

### How to drop privileges

When it comes to executing a service, no matter it's a service or a logging service, a very good practice is to drop privileges before executing it. `s6` already includes utilities to do exactly these kind of things:

In `execline`:

```sh
#!/usr/bin/env execlineb -P
s6-setuidgid daemon
myservice
```

In `sh`:

```sh
#!/usr/bin/env sh
exec s6-setuidgid daemon myservice
```

If you want to know more about these utilities, please take a look to: [`s6-setuidgid`](http://skarnet.org/software/s6/s6-setuidgid.html), [`s6-envuidgid`](http://skarnet.org/software/s6/s6-envuidgid.html) and [`s6-applyuidgid`](http://skarnet.org/software/s6/s6-applyuidgid.html).

### How to allow high inheritance
* It's convenient to prefix every scripts in `envs`, `perms`, `init` and `finalize` by number (two chars) to ensure execution order.
* A common pattern is to dedicated 10 number by docker image layer to allow logic evolution.

## Contributing
If you find this project useful here's how you can help :

* Send a Pull Request with your awesome new features and bug fixed
* Be a part of the ommunity and help resolve [Issues](https://github.com/amannocci/ignity/issues)
