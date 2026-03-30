pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'wael558'
        FRONTEND_IMAGE = "${DOCKERHUB_USER}/waelto5clean-frontend"
        BACKEND_IMAGE  = "${DOCKERHUB_USER}/waelto5clean-backend"
        IMAGE_TAG      = "${BUILD_NUMBER}"
        SONAR_HOST     = 'http://172.17.0.1:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/wael-khadraoui/WaelTo5Clean.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Install Dependencies') {
            parallel {
                stage('Backend Deps') {
                    steps {
                        dir('backend') { sh 'npm install' }
                    }
                }
                stage('Frontend Deps') {
                    steps {
                        dir('frontend') { sh 'npm install' }
                    }
                }
            }
        }

        stage('Unit Tests') {
            steps {
                dir('backend') { sh 'npm test || true' }
            }
        }

        stage('SAST - SonarQube') {
            steps {
                withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=WaelTo5Clean \
                          -Dsonar.projectName=WaelTo5Clean \
                          -Dsonar.sources=backend/src,frontend/src \
                          -Dsonar.host.url=${SONAR_HOST} \
                          -Dsonar.login=${SONAR_TOKEN}
                    '''
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                sh '''
                    cd backend && npm audit --audit-level=high || true
                    cd ../frontend && npm audit --audit-level=high || true
                '''
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Frontend') {
                    steps {
                        sh "docker build -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -f docker/Dockerfile.frontend ."
                    }
                }
                stage('Build Backend') {
                    steps {
                        sh "docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -f docker/Dockerfile.backend ."
                    }
                }
            }
        }

        stage('Trivy Image Scan') {
            parallel {
                stage('Scan Frontend') {
                    steps {
                        sh "trivy image --severity HIGH,CRITICAL --exit-code 0 ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                    }
                }
                stage('Scan Backend') {
                    steps {
                        sh "trivy image --severity HIGH,CRITICAL --exit-code 0 ${BACKEND_IMAGE}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Snyk Security Scan') {
            steps {
                sh '''
                    snyk test --docker ${FRONTEND_IMAGE}:${IMAGE_TAG} --severity-threshold=high || true
                    snyk test --docker ${BACKEND_IMAGE}:${IMAGE_TAG} --severity-threshold=high || true
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}
                        docker push ${BACKEND_IMAGE}:${IMAGE_TAG}
                        docker tag ${FRONTEND_IMAGE}:${IMAGE_TAG} ${FRONTEND_IMAGE}:latest
                        docker tag ${BACKEND_IMAGE}:${IMAGE_TAG} ${BACKEND_IMAGE}:latest
                        docker push ${FRONTEND_IMAGE}:latest
                        docker push ${BACKEND_IMAGE}:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh '''
                    docker rmi ${FRONTEND_IMAGE}:${IMAGE_TAG} || true
                    docker rmi ${BACKEND_IMAGE}:${IMAGE_TAG} || true
                '''
            }
        }
    }

    post {
        success { echo 'Pipeline DevSecOps termine avec succes !' }
        failure { echo 'Pipeline echoue - verifier les logs' }
        always { cleanWs() }
    }
}
