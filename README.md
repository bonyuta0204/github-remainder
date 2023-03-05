# github-remainder


## install GitHub Remainder
You need to build and install from source.

### Mac OS
#### Getting the source code
```
git clone https://github.com/bonyuta0204/github-remainder.git
cd github-remainder
```

#### Build And Install
You need `stack` to for build.

```
stack setup
stack install
```

### Docker
Docker image is available at [dockerhub](https://hub.docker.com/repository/docker/bonyuta0204/github-remainder)

For example, You can list pull request like below.
```
docker run --rm -e GITHUB_TOKEN -e GITHUB_REPOSITORY="rails/rails" bonyuta0204/github-remainder
```