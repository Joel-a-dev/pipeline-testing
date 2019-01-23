def getCommit(){
  return sh(returnStdout: true, script: "git rev-parse HEAD | head -c 7").trim()
}

def getBuildTimestamp(){
  return sh(returnStdout: true, script: "date +'%Y-%m-%dT%H:%M:%SZ'").trim()
}

def getVersion(){
  //sh(script: "git fetch --tags")
  return sh(returnStdout: true, script: "git describe --tags --abbrev=0").toString().trim()
}

def run_bandit_test(){
  script{
    env.BRANCH=env.GIT_BRANCH.toLowerCase()
    env.COMMIT_SHA= sh(returnStdout: true, script: "git rev-parse HEAD | head -c 7").trim()
    env.CONTAINER="bandit-test-${COMMIT_SHA}"
    env.BANDIT_IMAGE="bandit-${BRANCH}"
    env.BANDIT_TAG="${COMMIT_SHA}"
  }
     dir('bandit'){
      sh(script:"bash ${BANDIT_DOCKER_SCRIPT}")
    }
    sh(script:"docker exec -i ${CONTAINER} chmod a+x /app_src/bandit/run_bandit.sh")
    return_s= sh(returnStatus:true, script:"docker exec -i ${CONTAINER} /app_src/bandit/run_bandit.sh")
    echo "${return_s}"
    sh "docker rm  -f ${CONTAINER}"
    sh "docker rmi -f ${BANDIT_IMAGE}:${BANDIT_TAG}"

    if ("${return_s}" != '0') {
      //archiveArtifacts artifacts: 'reports/banditReport.html'
      //publish report to build page
      publishHTML (target: [
        allowMissing: false,
        alwaysLinkToLastBuild: false,
        keepAll: true,
        reportDir: './reports',
        reportFiles: 'banditReport.html',
        reportName: "Bandit Report"
      ])
      error "Bandit test failed"
    }
}

def getVersioningVariables(){
    
    if (sh(returnStatus: true, script:"git describe --tags --abbrev=0") != '0'){
        sh "echo -e \"export GIT_COMMIT=\$(git rev-parse HEAD)\nexport GHE_VERSION=${SOURCE_BRANCH}-\$(git rev-parse HEAD | head -c 7)\nexport BUILD_TIMESTAMP=\$(date +'%Y-%m-%dT%H:%M:%SZ')\" > .version_vars.conf"
    }else{
        sh "echo -e \"export GIT_COMMIT=\$(git rev-parse HEAD)\nexport GHE_VERSION=\$(git describe --tags --abbrev=0)\nexport BUILD_TIMESTAMP=\$(date +'%Y-%m-%dT%H:%M:%SZ')\" > .version_vars.conf"
    }

    stash includes: ".version_vars.conf", name:"versionVars"
}

pipeline {
  agent any
  environment {
      GIT_COMMIT=getCommit()
      dir=pwd()
      INIT_GENERATOR_SCRIPT='generate-init-py.sh'
      // Bandit Test
        BANDIT_DOCKER_SCRIPT= 'bandit_test_docker.sh'
    }
    
  stages {
    stage("env"){
      agent any
      steps{
        echo sh(returnStdout: true, script: 'env')
      }
    }
    stage("Init"){
      agent any
      steps{
        echo "Init Stage"
        getVersioningVariables()
      }
    }
    stage("Main Pipeline"){
      parallel{
        stage("Testing") {
          agent any
          steps{
            echo "Testing Stage"
          }
        }
        stage("build") {
          agent any
          steps {
            echo "Build Stage"
          }
        }
      }
    }
    stage("publish"){
      steps{
        echo "Publish Stage"
      }
    }
  }
  
  // Post in Stage executes at the end of Stage instead of end of Pipeline
  post {
    always{
      deleteDir()
    }
    success {
      echo "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
    }
    unstable {
      echo "UNSTABLE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
    }
    failure {
      echo "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
    }
  }
}

