pipeline {
    agent any

    environment {
        GCP_REGION = 'europe-west2'
        GCP_PROJECT_ID = 'gcp-classes-395503'
        GCP_ARTIFACT_REGISTRY = 'us-central1-docker.pkg.dev'
        GCP_REPOSITORY = 'my-first-docker-registry'
        GKE_CLUSTER_NAME = 'node-app-gke-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', changelog: false, credentialsId: 'git_creds', poll: false, url: 'https://github.com/akaspatranobis/joindevops-project.git'
            }
        }

        stage('Setup GCP Credentials') {
            steps {
                // Copy the GCP service account key to a file and set the environment variable
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS_JSON')]) {
                    sh 'cp $GOOGLE_APPLICATION_CREDENTIALS_JSON terraform/gcp-key.json'
                    script {
                        env.GOOGLE_APPLICATION_CREDENTIALS = "${pwd()}/terraform/gcp-key.json"
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    // Initialize Terraform with the GCP credentials
                    sh 'terraform init '
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    // Plan Terraform changes with the GCP credentials
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    // Apply Terraform changes with the GCP credentials
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Install Web Dependencies') {
            steps {
                dir('node-web') {
                    sh 'npm install'
                }
            }
        }

        stage('Install API Dependencies') {
            steps {
                dir('node-api') {
                    sh 'npm install'
                }
            }
        }

        stage('Build Web Docker Image') {
            steps {
                dir('node-web') {
                    script {
                        dockerImageWeb = docker.build("${GCP_ARTIFACT_REGISTRY}/${GCP_PROJECT_ID}/${GCP_REPOSITORY}/web:latest", "-f Dockerfile .")
                    }
                }
            }
        }

        stage('Build API Docker Image') {
            steps {
                dir('node-api') {
                    script {
                        dockerImageAPI = docker.build("${GCP_ARTIFACT_REGISTRY}/${GCP_PROJECT_ID}/${GCP_REPOSITORY}/api:latest", "-f Dockerfile .")
                    }
                }
            }
        }

        stage('Push Docker Images to GCP Artifact Registry') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS_JSON')]) {
                        sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS_JSON'
                        sh 'gcloud auth configure-docker ${GCP_ARTIFACT_REGISTRY}'
                    }
                    dockerImageWeb.push('latest')
                    dockerImageAPI.push('latest')
                }
            }
        }

        stage('Deploy to GKE') {
            steps {
                dir('k8s') {
                    script   {
                        withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS_JSON')]) {
                        sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS_JSON'
                        sh 'gcloud config set project $GCP_PROJECT_ID'
                        sh 'gcloud container clusters get-credentials $GKE_CLUSTER_NAME --region $GCP_REGION --project $GCP_PROJECT_ID'
                    }
                        sh 'kubectl apply -f db-secret.yaml'
                        sh 'kubectl apply -f node-web-manifest.yaml'
                        sh 'kubectl apply -f node-api-manifest.yaml'
                    }
                }    
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
