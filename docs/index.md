
![bluebeluga/alpine](https://raw.githubusercontent.com/blue-beluga/docker-alpine/master/docs/images/bluebeluga.png)

# bluebeluga/alpine


[![CircleCI](https://circleci.com/gh/riddopic/docker-alpine.svg?style=svg)](https://circleci.com/gh/riddopic/docker-alpine)
[![](https://images.microbadger.com/badges/image/bluebeluga/alpine.svg)](https://microbadger.com/images/bluebeluga/alpine "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/bluebeluga/alpine.svg)](https://microbadger.com/images/bluebeluga/alpine "Get your own version badge on microbadger.com")

A minimalist [Alpine Linux](http://alpinelinux.org/) container.

```
REPOSITORY          TAG           IMAGE ID          VIRTUAL SIZE
bluebeluga/alpine   latest        c2d2631a367f      5.469 MB
alpine              latest        baa5d63471ea      4.803 MB
debian              latest        4d6ce913b130      84.98 MB
ubuntu              latest        b39b81afc8ca      188.3 MB
centos              latest        8efe422e6104      210 MB
```

## Installation and Usage

A contains should only contain the OS libraries and language dependencies required to run an application and the application itself.

## Example

Rather than starting with everything but the kitchen sink, start with the **bare minimum and add dependencies** on an as needed basis.

```
FROM bluebeluga/alpine:3.5
RUN apk add --update dnsmasq \
 && rm -rf /var/cache/apk/*
EXPOSE 53 53/udp
ENTRYPOINT ["dnsmasq", "-k"]
```

We now have a very small container with only the dependencies we need. Nothing more.

## Disabling Cache

As of Alpine Linux 3.3 there exists a new `--no-cache` option for `apk`. It allows users to install packages with an index that is updated and used on-the-fly and not cached locally:

```
FROM bluebeluga/alpine:3.5
RUN apk --no-cache add dnsmasq
EXPOSE 53 53/udp
ENTRYPOINT ["dnsmasq", "-k"]
```

This avoids the need to use `--update` and remove `/var/cache/apk/*` when done installing packages.

## Cleanup

This image contains a wrapper script that assists in the cleanup of the package index after installing packages. Here is another simple `Dockerfile` that installs the `nginx` package and removes package index data:

```
FROM bluebeluga/alpine:3.5
RUN apk-install nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Virtual Packages

Another great apk add feature for cleanup is the concept of virtual packages using the `--virtual` or `-t` switch. Packages added under this virtual name can then be removed as one group. An example use of this would be removing a group of build dependencies all at once:

```
FROM bluebeluga/alpine:3.5
RUN apk --update add python py-pip openssl ca-certificates
RUN apk --update add --virtual build-dependencies python-dev build-base wget \
  && pip install -r requirements.txt \
  && python setup.py install \
  && apk del build-dependencies
CMD ["myapp", "start"]
```

## Available Tags

* `latest`: **Currently 3.5**
* `3.2`:
* `3.3`:
* `3.4`
* `3.5`
* `edge`:

## Build

Build the container:

    make build

## Test

Run automated tests on one or more instances:

    make test

## Push

Push image or a repository to the registry:

    make push

## Clean

Stop and remove build artifacts and images:

    make clean

## Contributing

Please see the [CONTRIBUTING.md](CONTRIBUTING.md).

## License and Authors

```
MIT License

Copyright (c) 2016 The Blue Beluga Company

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
