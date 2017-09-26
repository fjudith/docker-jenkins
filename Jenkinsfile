pipeline {
    agent any
    environment {
        REPO = 'fjudith/jenkins'
    }
    stages {
        stage ('Prepare') {
            steps {
                script {
                    if ("${BRANCH_NAME}" == "master"){
                        TAG = "latest"
                        NGINX = "nginx"
                        SLAVE = "slave"
                    }
                    else {
                        TAG = "${BRANCH_NAME}"
                        NGINX = "${BRANCH_NAME}-nginx"
                        SLAVE = "${BRANCH_NAME}-slave"
                    }
                }
                stash name: 'everything',
                      includes: '**'
            }
        }
        stage ('Docker build'){
            parallel {
                stage ('Jenkins Application server') {
                    agent { label 'linux'}
                    steps {
                        sh 'rm -rf *'
                        unstash 'everything'
                        sh 'tree -sh'
                        sh "docker build -f Dockerfile -t ${REPO}:${GIT_COMMIT} ."
                    }
                }
                stage ('Jenkins Nginx server') {
                    agent { label 'linux'}
                    steps {
                        sh 'rm -rf *'
                        unstash 'everything'
                        sh 'tree -sh'
                        sh "docker build -f nginx/Dockerfile -t ${REPO}:${GIT_COMMIT}-nginx nginx/"
                    }
                }
                stage ('Jenkins Slave agent') {
                    agent { label 'linux'}
                    steps {
                        sh 'rm -rf *'
                        unstash 'everything'
                        sh 'tree -sh'
                        sh "docker build -f slave/Dockerfile -t ${REPO}:${GIT_COMMIT}-slave slave/"
                    }
                }
            }
        }
        stage ('Test') {
            steps {
                echo 'Deploying...'
                sh "docker tag ${REPO}:${GIT_COMMIT} ${REPO}:${TAG}"
                sh "docker images"
            }
        }
    }
}