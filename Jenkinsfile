
pipeline {
  agent { label 'docker' }

    stage('Build Alpine') {
      steps {
        ansiColor('xterm') {
          sh "make build"
        }
      }
    }

    stage('Test Alpine') {
      steps {
        ansiColor('xterm') {
          sh "docker run -d --cidfile .cid bluebeluga/alpine:3.5 sleep 180"
          sh "docker run -it --rm -v .:/share -v /var/run/docker.sock:/var/run/docker.sock chef/inspec exec test/ --format=doc -t docker://$(cat .cid)"
        }
      }
    }
  }
}
