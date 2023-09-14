String credentialsId = 'awsCredentials'

pipeline {
    agent {
        kubernetes {
            yaml '''
              apiVersion: v1
              kind: Pod
              spec:
                containers:
                - name: terraform
                  image: hashicorp/terraform
                  command:
                  - cat
                  tty: true
            '''
        }
    }

    stages {
        stage('terraform init'){
            steps{
                container('terraform'){
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: credentialsId,
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]]) {
                              sh 'terraform init'
                    }
                }
            }
        }
        stage('terraform plan -destroy'){
            steps{
                container('terraform'){
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: credentialsId,
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]]) {
                              sh 'terraform plan -destroy -out tfplan'
                              sh 'terraform show -no-color tfplan > tfplan.txt'
                    }
                }
            }
        }
        stage('Approval') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }
        stage('terraform destroy'){
           when {
                branch 'main'
            }
            steps{
                container('terraform'){
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: credentialsId,
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]]) {
                              sh 'echo test'
                              sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}
