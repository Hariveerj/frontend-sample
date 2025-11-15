pipeline {
    agent any

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'hari',
                    url: 'https://github.com/Hariveerj/frontend-sample.git',
                    credentialsId: 'github-token'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // Use the scanner tool configured in Global Tool Configuration
                    def scannerHome = tool 'sonar-scanner'

                    // "sonarqube" here must match the Name in "SonarQube servers" config
                    withSonarQubeEnv('sonarqube') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                              -Dsonar.projectKey=frontend-sample \
                              -Dsonar.projectName=frontend-sample \
                              -Dsonar.sources=.
                        """
                    }
                }
            }
        }

        stage('Build') {
            steps {
                echo "Building..."
            }
        }

        stage('Test') {
            steps {
                echo "Testing..."
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying..."
            }
        }
    }
}
