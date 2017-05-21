
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
          sh "make test"
        }
      }
    }
  }
}
