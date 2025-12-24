pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {

        stage('Git checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'githubcred5',
                    url: 'https://github.com/mouradaouraghe/FullStack-Blogging-App.git'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('File System Scan') {
            steps {
                sh 'trivy fs --format table -o trivy-report.html .'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh """
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=FullStack-Blogging-App \
                    -Dsonar.projectKey=FullStack-Blogging-App \
                    -Dsonar.java.binaries=.
                    """
                }
            }
        }

        stage('Build') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Publish artifacts to Nexus') {
            steps {
                withMaven(
                    globalMavenSettingsConfig: 'global-settings',
                    jdk: 'jdk17',
                    maven: 'maven3',
                    traceability: true
                ) {
                    sh 'mvn deploy'
                }
            }
        }

        // ------------------------
        // Docker stages (CLASSIQUE)
        // ------------------------
        stage('Build Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockercred', toolName: 'docker') {
                        sh 'docker build --no-cache -t charifray/blogginapp:latest .'
               
                    }
                }
            }
        }

        stage('Image Scan') {
            steps {
                sh 'trivy image --format table -o trivy-image-report.html charifray/blogginapp:latest'
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockercred', toolName: 'docker') {
                        sh 'docker push charifray/blogginapp:latest'
                    }
                }
            }
        }

        // ------------------------
        // Kubernetes deployment
        // ------------------------
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig(
                    credentialsId: 'kubesecret1',
                    clusterName: 'BONJOUR10',
                    namespace: 'default',
                    serverUrl: 'https://bonjour10-rg-aks-demo5-1a48f6-3laxtuto.hcp.germanywestcentral.azmk8s.io:443'
                ) {
                    sh 'kubectl apply -f deploysvc.yaml'
                    sh 'kubectl apply -f ingress.yaml'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withKubeConfig(
                    credentialsId: 'kubesecret1',
                    clusterName: 'BONJOUR10',
                    namespace: 'default',
                    serverUrl: 'https://bonjour10-rg-aks-demo5-1a48f6-3laxtuto.hcp.germanywestcentral.azmk8s.io:443'
                ) {
                    sh 'kubectl get pods'
                    sh 'kubectl get svc'
                }
            }
        }
    }

    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'SUCCESS'
                def bannerColor = pipelineStatus == 'SUCCESS' ? 'green' : 'red'

                def body = """
                <html>
                <body>
                    <div style="border:4px solid ${bannerColor}; padding:10px;">
                        <h2>${jobName} - Build ${buildNumber}</h2>
                        <div style="background-color:${bannerColor}; padding:10px;">
                            <h3 style="color:white;">
                                Pipeline Status: ${pipelineStatus}
                            </h3>
                        </div>
                        <p>Check <a href="${BUILD_URL}">console output</a></p>
                    </div>
                </body>
                </html>
                """

                emailext(
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus}",
                    body: body,
                    to: 'otazatv1@gmail.com',
                    mimeType: 'text/html',
                    attachmentsPattern: 'trivy-image-report.html'
                )
            }
        }
    }
}
