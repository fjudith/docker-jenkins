// 
// https://github.com/jenkinsci/pipeline-model-definition-plugin/wiki/Syntax-Reference
// https://jenkins.io/doc/book/pipeline/syntax/#parallel
// https://jenkins.io/doc/book/pipeline/syntax/#post
pipeline {
    agent any
    environment {
        REPO = 'fjudith/jenkins'
        PRIVATE_REPO = "${PRIVATE_REGISTRY}/${REPO}"
        DOCKER_PRIVATE = credentials('docker-private-registry')
    }
    stages {
        stage ('Checkout') {
            steps {
                script {
                    COMMIT = "${GIT_COMMIT.substring(0,8)}"

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
                }
                sh 'printenv'
            }
        }
        stage ('Docker build Micro-Service') {
            parallel {
                stage ('Jenkins application server'){
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f Dockerfile -t ${REPO}:${COMMIT} ./"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT} ${PRIVATE_REPO}:${TAG}"
                        }
                    }
                }
                stage ('Nginx web server') {
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f nginx/Dockerfile -t ${REPO}:${COMMIT}-nginx nginx/"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT}-nginx ${PRIVATE_REPO}:${NGINX}"
                        }
                    }
                }
                stage ('Jenkins slave/agent') {
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f slave/Dockerfile -t ${REPO}:${COMMIT}-slave slave/"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT}-slave ${PRIVATE_REPO}:${SLAVE}"
                        }
                    }
                }
            }
        }
        stage ('Run'){
            agent { label 'docker'}
                steps {
                    // Create Network
                    sh "docker network create jenkins-${BUILD_NUMBER}"
                    //Start application micro-services
                    sh "docker run -d --name 'jenkins-${BUILD_NUMBER}' --network jenkins-${BUILD_NUMBER} ${REPO}:${COMMIT}"
                    sh "docker run -d --name 'slave-${BUILD_NUMBER}'   --network jenkins-${BUILD_NUMBER} ${REPO}:${COMMIT}-slave"
                    sh "docker run -d --name 'nginx-${BUILD_NUMBER}'   --network jenkins-${BUILD_NUMBER} --link jenkins-${BUILD_NUMBER}:jenkins ${REPO}:${COMMIT}-nginx"
                    // Get container IDs
                    script {
                        DOCKER_JENKINS = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}", returnStdout: true).trim()
                        DOCKER_SLAVE   = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}-slave", returnStdout: true).trim()
                        DOCKER_NGINX   = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}-nginx", returnStdout: true).trim()
                    }
                }
            }
        }
        stage ('Test'){
            agent { label 'docker'}
            steps {
                sleep 60
                // Internal
                sh "docker exec jenkins-${BUILD_NUMBER} /bin/bash -c 'curl -iL -X GET http://localhost:8080'"
                sh "docker exec slave-${BUILD_NUMBER} /bin/bash -c 'ss -an'"
                sh "docker exec nginx-${BUILD_NUMBER} /bin/bash -c 'curl -iL -X GET -u admin:admin http://localhost:80'"
                // Cross Container
                sh "docker exec ${DOCKER_SLAVE} /bin/bash -c 'curl -iL -X GET http://${DOCKER_JENKINS}:8080'"
                sh "docker exec ${DOCKER_SLAVE} /bin/bash -c 'curl -iL -X GET http://${DOCKER_JENKINS}:50000'"
                sh "docker exec ${DOCKER_NGINX} /bin/bash -c 'curl -iL -X GET http://${DOCKER_JENKINS}:8080'"
                // External
                sh "docker run --rm --network jenkins-${BUILD_NUMBER} blitznote/debootstrap-amd64:17.04 bash -c 'curl -i -X GET http://${DOCKER_NGINX}:80'"
            }
            post {
                always {
                    echo 'Remove micro-services stack'
                    sh "docker rm -vf jenkins-${BUILD_NUMBER}"
                    sh "docker rm -vf slave-${BUILD_NUMBER}"
                    sh "docker rm -vf nginx-${BUILD_NUMBER}"
                    sh "docker network rm jenkins-${BUILD_NUMBER}"
                }
                success {
                    sh "docker login -u ${DOCKER_PRIVATE_USR} -p ${DOCKER_PRIVATE_PSW} ${PRIVATE_REGISTRY}"
                    sh "docker push ${PRIVATE_REPO}:${TAG}"
                    sh "docker push ${PRIVATE_REPO}:${SLAVE}"
                    sh "docker push ${PRIVATE_REPO}:${NGINX}"
                }
            }
        }
    }
    post {
        always {
            echo 'Run regardless of the completion status of the Pipeline run.'
        }
        changed {
            echo 'Only run if the current Pipeline run has a different status from the previously completed Pipeline.'
        }
        success {
            echo 'Only run if the current Pipeline has a "success" status, typically denoted in the web UI with a blue or green indication.'

        }
        unstable {
            echo 'Only run if the current Pipeline has an "unstable" status, usually caused by test failures, code violations, etc. Typically denoted in the web UI with a yellow indication.'
        }
        aborted {
            echo 'Only run if the current Pipeline has an "aborted" status, usually due to the Pipeline being manually aborted. Typically denoted in the web UI with a gray indication.'
        }
    }
}