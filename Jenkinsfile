// Jenkinsfile — automates the Renesas -> HE3 pipeline.
//
// Agent: this pipeline assumes it runs on (or has SSH reach to) the
// machine with the toolchains installed — i.e. the "build machine"
// from the README. Point the `agent { label ... }` line at that node.
//
// This mirrors the CLI exactly: `./hoags-build <cmd> [eterna] [lotier]
// [--build-type X] [--ci]`. Swap new_build_system/hoags-build for the
// real script and nothing here needs to change.

pipeline {
    agent { label 'renesas-build' }   // <- Jenkins node with the toolchains

    parameters {
        choice(
            name: 'PLATFORM',
            choices: ['BOTH', 'RA', 'RL78'],
            description: 'Which firmware to build'
        )
        choice(
            name: 'BUILD_TYPE',
            choices: ['dev', 'test', 'mp'],
            description: 'Build type passed to hoags-build --build-type'
        )
        booleanParam(
            name: 'RUN_HE3',
            defaultValue: true,
            description: 'If true, run full "he3" (push + HE3 build). If false, only "firmware" (pull+compile+convert, no push).'
        )
        booleanParam(
            name: 'CI_MODE',
            defaultValue: false,
            description: 'Pass --ci (S3 upload + OTA manifest rewrite). Off by default, same as the CLI.'
        )
    }

    options {
        // Refuse to overlap with another run of this job, same intent
        // as the flock in the mail-trigger design.
        disableConcurrentBuilds()
        timestamps()
        timeout(time: 90, unit: 'MINUTES')
    }

    triggers {
        // Push-triggered via the GitHub webhook configured in Jenkins
        // (see setup steps). Safe to leave even if you also kick this
        // job off manually with parameters.
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Doctor') {
            steps {
                sh './new_build_system/hoags-build doctor'
            }
        }

        stage('Build') {
            steps {
                script {
                    def platformArg = [
                        'BOTH': '',
                        'RA':   'lotier',
                        'RL78': 'eterna',
                    ][params.PLATFORM]

                    def cmd = params.RUN_HE3 ? 'he3' : 'firmware'
                    def ciFlag = params.CI_MODE ? '--ci' : ''

                    sh """
                        cd new_build_system
                        ./hoags-build ${cmd} ${platformArg} --build-type ${params.BUILD_TYPE} ${ciFlag}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Build succeeded: platform=${params.PLATFORM} type=${params.BUILD_TYPE} he3=${params.RUN_HE3} ci=${params.CI_MODE}"
        }
        failure {
            echo "Build failed — check the 'Build' stage log above."
        }
        always {
            archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
        }
    }
}
