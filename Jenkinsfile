pipeline {
    agent any

    triggers {
        gitlab branchFilterType: 'All', excludeBranchesSpec: '', includeBranchesSpec: '', noteRegex: 'Jenkins please retry a build', pendingBuildName: '', secretToken: '', skipWorkInProgressMergeRequest: true, sourceBranchRegex: '', targetBranchRegex: '', triggerOnApprovedMergeRequest: true, triggerOpenMergeRequestOnPush: 'never'
    }

    parameters {
        string(name: 'PORT', defaultValue: '8081', description: 'Port number to expose')
        string(name: 'VERSION', defaultValue: 'EOS')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '**']], extensions: [[$class: 'WipeWorkspace']], userRemoteConfigs: [[credentialsId: 'gilabb', url: 'http://gitlab/Saeed/cowsay-versioned.git']])
            }
        }

        stage('createVersion') {
            when { expression { (env.GIT_BRANCH == 'main' && params.VERSION != 'EOS') || env.GIT_BRANCH ==~ /release\/.*/} }
            steps {
                script {
                    if (params.VERSION == "EOS") {
                        ver = sh(script: "echo ${env.GIT_BRANCH} | cut -d / -f 2", returnStdout: true).trim()
                        params.VERSION = ver
                    }
                    exitcode = sh(script: "git checkout release/${params.VERSION}", returnStatus: true)
                    echo "${exitcode}"
                    if (exitcode) {
                    sh """
                        git checkout -b release/${params.VERSION}
                        echo ${params.VERSION} >> v.txt
                        git commit v.txt -m "release version"
                        git push -u origin release/${params.VERSION}
                    """
                    }
                
                    lasttag = sh(script: "git tag -l --sort=version:refname \"v${params.VERSION}.*\" | tail -1", returnStdout: true).trim()
                    def newtag
                    if (lasttag.isEmpty()) {
                        sh "git tag v${params.VERSION}.0"
                        newtag = "v${params.VERSION}.0"
                    } else {
                        newtag = lasttag.split('\\.')
                        newtag[2] = newtag[2].toInteger() + 1
                        newtag = newtag.join('.')
                        sh "git tag ${newtag}"
                    }
                    NEWTAG = newtag
                    sh "git push --tags"
                }
            }
        }
        
        stage('Build and Run Docker Container') {
            steps {
                sh " ./init-cowsay.sh -p ${params.PORT} -v ${NEWTAG}"
            }
        }

        stage('Test') {
            steps {
                script {
                    def status = sh(
                        script: """ sleep 5
                                    sh test.sh ${params.PORT}
                                """,
                        returnStatus: true
                    )
                    
                    if (status == 0) {
                        echo 'Cowsay web app check passed'
                    } else {
                        error 'Cowsay web app check failed'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'deploy ...'
            }
        }

    }

    post {
        always {
            // Cleanup stage
            
            script {
                sh "docker stop cowsay-${NEWTAG}"
                sh 'docker system prune -af'
                cleanWs()
            }
        }
    }

}
