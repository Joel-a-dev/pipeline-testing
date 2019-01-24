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

def getVersioningVariables(){
    is_tagged=sh(returnStatus: true,returnStdout:false, script:"#!/bin/sh \n git describe --tags --abbrev=0")

    if ( is_tagged != '0'){
        sh "echo  \"export GIT_COMMIT=\$(git rev-parse HEAD)\nexport GHE_VERSION=${BRANCH_NAME}-\$(git rev-parse HEAD | head -c 7)\nexport BUILD_TIMESTAMP=\$(date +'%Y-%m-%dT%H:%M:%SZ')\" > .version_vars.conf"
    }else{
        sh "echo  \"export GIT_COMMIT=\$(git rev-parse HEAD)\nexport GHE_VERSION=\$(git describe --tags --abbrev=0)\nexport BUILD_TIMESTAMP=\$(date +'%Y-%m-%dT%H:%M:%SZ')\" > .version_vars.conf"
    }
    stash includes: ".version_vars.conf", name:"versionVars"
}

pipeline {
  agent any
  environment {
      GIT_COMMIT=getCommit()
      dir=pwd()
      PY_GEN_SCRIPT='generate_py_init.sh'
    }
    
    
  stages {
    stage("env"){
      agent any
      steps{
        echo sh(returnStdout: true, script: 'env')
        sh "echo ${currentBuild.buildCauses}"
      }
      
    }
    stage("Init"){
      agent any
      steps{
        echo "Init Stage"
        getVersioningVariables()
        sh "cat .version_vars.conf"
        sh "bash ${PY_GEN_SCRIPT}"
        sh "cat ___init___.py"
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

