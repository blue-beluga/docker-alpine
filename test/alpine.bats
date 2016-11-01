#!/usr/bin/env bats

load test_helper

@test "version is correct" {
  run docker run $REGISTRY/$REPOSITORY:$TAG cat /etc/os-release
  [ $status -eq 0 ]
  if [ "$TAG" = "edge" ]; then
    [[ "${lines[2]}" == "VERSION_ID=3.4.0" ]]
  else
    [[ "${lines[2]}" == "VERSION_ID=$TAG."* ]]
  fi
}

@test "running 64-bit kernel" {
  run bash -c "uname -a | grep -o x86_64 | wc -m"
  [ "$status" -eq 0 ]
}

@test "git installs cleanly" {
  run docker run $REGISTRY/$REPOSITORY:$TAG apk add --update git
  [ "$status" -eq 0 ]
}

@test "git executes correctly" {
  run docker run $REGISTRY/$REPOSITORY:$TAG sh -c \
    "apk add --update git && git --version"
  [ "$status" -eq 0 ]
}

@test "timezone set to UTC" {
  run docker run $REGISTRY/$REPOSITORY:$TAG date +%Z
  [ $status -eq 0 ]
  [ "$output" = "UTC" ]
}

@test "apk-install script should be available" {
  run docker run $REGISTRY/$REPOSITORY:$TAG which apk-install
  [ $status -eq 0 ]
}

@test "repository list is correct" {
  run docker run $REGISTRY/$REPOSITORY:$TAG cat /etc/apk/repositories
  [ $status -eq 0 ]

  if [ "$TAG" -le "3.2" ]; then
    [[ "${lines[0]}" == "http://dl-cdn.alpinelinux.org/alpine/v$TAG/main" ]]
    [[ "${lines[2]}" == "" ]]
  elif [ "$TAG" = "edge" ]; then
    [[ "${lines[0]}" == "http://dl-cdn.alpinelinux.org/alpine/$TAG/main" ]]
    [[ "${lines[1]}" == "http://dl-cdn.alpinelinux.org/alpine/$TAG/community" ]]
    [[ "${lines[2]}" == "" ]]
  else
    [[ "${lines[0]}" == "http://dl-cdn.alpinelinux.org/alpine/v$TAG/main" ]]
    [[ "${lines[1]}" == "http://dl-cdn.alpinelinux.org/alpine/v$TAG/community" ]]
    [[ "${lines[2]}" == "" ]]
  fi
}

@test "cache is empty" {
  run docker run $REGISTRY/$REPOSITORY:$TAG sh -c "ls -1 /var/cache/apk | wc -l"
  [ $status -eq 0 ]
}

@test "current user" {
  run docker run $REGISTRY/$REPOSITORY:$TAG whoami
  [ $status -eq 0 ]
  [ "$output" = "root" ]
}

@test "root password is disabled" {
  run docker run --user nobody $REGISTRY/$REPOSITORY:$TAG su
  [ $status -eq 1 ]
}

@test "protects from CVE-2016-2183, CVE-2016-6304, CVE-2016-6306, CVE-2016-7052" {
  if [ "$TAG" -eq "3.1" ]; then
    run docker run $REGISTRY/$REPOSITORY:$TAG \
      sh -c 'apk version -t $(apk info -v | grep ^libssl | cut -d- -f2-) 1.0.1u-r0 | grep -q "[=>]"'
    [ $status -eq 0 ]
    run docker run $REGISTRY/$REPOSITORY:$TAG \
      sh -c 'apk version -t $(apk info -v | grep ^libssl | cut -d- -f2-) 1.0.2j-r0 | grep -q "[=>]"'
    [ $status -eq 0 ]
  else
    run docker run $REGISTRY/$REPOSITORY:$TAG \
      sh -c 'apk version -t $(apk info -v | grep ^libssl | cut -d- -f2-) 1.0.2i-r0 | grep -q "[=>]"'
    [ $status -eq 0 ]
    run docker run $REGISTRY/$REPOSITORY:$TAG \
      sh -c 'apk version -t $(apk info -v | grep ^libssl | cut -d- -f2-) 1.0.2j-r0 | grep -q "[=>]"'
    [ $status -eq 0 ]
  fi
}

@test "image size" {
  run docker images $REGISTRY/$REPOSITORY:$TAG
  size="$(echo ${lines[1]} | awk -F '   *' '{ print int($5) }')"
  echo 'size:' $size
  [ $status -eq 0 ]
  [ $size -lt 10 ]
}
