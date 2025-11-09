pipeline {
  agent any
  environment {
    NEXUS_REPO = 'nexus.example.com:5000'
    IMAGE_NAME = "${NEXUS_REPO}/frontend-sample"
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Install & Test') {
      steps {
        sh 'npm ci'
        sh 'npm test || true'
      }
    }
    stage('SonarQube Scan') {
      environment {
        SONAR_TOKEN = credentials('sonar-token')
      }
      steps {
        withSonarQubeEnv('MySonarQube') {
          sh 'npx sonar-scanner -Dsonar.login=$SONAR_TOKEN'
        }
      }
    }
    stage('Build Docker Image') {
      steps {
        script {
          sh """
            docker login ${NEXUS_REPO} -u ${NEXUS_USER} -p ${NEXUS_PASS}
            docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
            docker push ${IMAGE_NAME}:${BUILD_NUMBER}
          """
        }
      }
    }
    stage('Deploy to Slave') {
      agent { label 'deploy' }
      steps {
        sh """
          docker pull ${IMAGE_NAME}:${BUILD_NUMBER}
          docker rm -f frontend-sample || true
          docker run -d --name frontend-sample -p 3000:80 \
            --memory=512m --memory-reservation=256m ${IMAGE_NAME}:${BUILD_NUMBER}
        """
      }
    }
  }
  post {
    success {
      mail to: 'harivasanthj@gmail.com',
           subject: "Frontend Pipeline SUCCESS #${BUILD_NUMBER}",
           body: "Deployed successfully! ${BUILD_URL}"
    }
    failure {
      mail to: 'harivasanthj@gmail.com',
           subject: "Frontend Pipeline FAILED #${BUILD_NUMBER}",
           body: "Check logs: ${BUILD_URL}"
    }
  }
}
