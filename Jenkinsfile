
pipeline {
  agent { label 'docker' }

  stages {
    stage('Get dependencies') {
      steps {
        ansiColor('xterm') {
          sh "make deps"
        }
      }
    }

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
