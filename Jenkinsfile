pipeline {
    agent { label 'slave' }

    environment {
        // Jenkins credentials
        GIT_CRED = credentials('githubtoken')
        SONAR_TOKEN = credentials('sonar-token')
        NEXUS_CREDS = credentials('nexus-creds')

        // Servers
        SONARQUBE_SERVER = 'http://13.201.250.77:9000'
        NEXUS_URL = 'http://13.201.250.77:8081/repository/docker-releases/'

        // Docker config
        IMAGE_NAME = 'frontend-app'
        IMAGE_TAG = "v${env.BUILD_NUMBER}"

        // Memory control for container
        MEMORY_LIMIT = "768m"
        JAVA_OPTS = "-Xms256m -Xmx768m"
    }

    stages {

        stage('🔹 Checkout Code') {
            steps {
                echo "Fetching source code from GitHub..."
                git branch: "${env.BRANCH_NAME}",
                    credentialsId: "${GIT_CRED}",
                    url: 'https://github.com/Hariveerj/frontend-app.git'
            }
        }

        stage('🔹 SonarQube Scan') {
            steps {
                echo "Running SonarQube scan..."
                withSonarQubeEnv('sonarqube') {
                    sh """
                        sonar-scanner \
                        -Dsonar.projectKey=frontend-app \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=${SONARQUBE_SERVER} \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        stage('🔹 Build Docker Image') {
            steps {
                echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}..."
                sh """
                    docker build --memory=${MEMORY_LIMIT} --memory-swap=1g -t ${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('🔹 Run Unit Tests in Container') {
            steps {
                echo "Running container and executing test cases..."
                sh """
                    docker rm -f ${IMAGE_NAME}-test || true
                    docker run -d --name ${IMAGE_NAME}-test \
                        --memory=${MEMORY_LIMIT} \
                        ${IMAGE_NAME}:${IMAGE_TAG}

                    sleep 10
                    docker exec ${IMAGE_NAME}-test npm test || true
                    docker logs ${IMAGE_NAME}-test
                """
            }
        }

        stage('🔹 Push to Nexus Repository') {
            steps {
                echo "Pushing Docker image to Nexus..."
                sh """
                    echo "${NEXUS_CREDS_PSW}" | docker login -u "${NEXUS_CREDS_USR}" --password-stdin 13.201.250.77:8081
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} 13.201.250.77:8081/docker-releases/${IMAGE_NAME}:${IMAGE_TAG}
                    docker push 13.201.250.77:8081/docker-releases/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('🔹 Deploy & Run Container') {
            steps {
                echo "Deploying application container..."
                sh """
                    docker rm -f ${IMAGE_NAME} || true
                    docker run -d --name ${IMAGE_NAME} \
                        -p 3000:3000 \
                        --memory=${MEMORY_LIMIT} \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully for ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Build failed. Please check logs."
        }
    }
}
