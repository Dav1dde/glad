pipeline {
    agent any
    stages {
        stage('Setup') {
            steps {
                sh 'git reset --hard HEAD'
                sh 'git clean -xffd'
            }
        }
        stage('Test') {
            parallel {
                stage('Unit') {
                    steps {
                        withPythonEnv('python2') {
                            sh 'python -m pip install -r requirements.txt'
                            sh 'python -m pip install -r requirements-test.txt'
                            sh 'python -m nose --with-xunit || true'
                            junit 'nosetests.xml'
                        }
                    }
                }
                stage('Integration') {
                    steps {
                        sh 'docker pull dav1d/glad-test'
                        sh 'docker run --rm -t -v "$WORKSPACE:/mnt" --user "$(id -u):$(id -g)" dav1d/glad-test || true'
                        junit 'test-report.xml'
                    }
                }
            }
        }
    }
}
