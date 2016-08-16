#!/bin/bash

set -e

#configuration
apiIssueBaseUrl='https://api.github.com/repos/zxwing/mevoco-ui/issues/'
httpIssueBaseUrl='https://github.com/zxwing/mevoco-ui/issues/'
uid=
password=
masterBase=master
branchBase=1.6.x
remoteOrigin=origin
remoteMy=my
mevocoPath=~/Documents/coding/web/mevoco-ui/

cd $mevocoPath
#get issue Id
if [ -z "$1" ]
then
    echo "Usage: your must specify a issue Number."
    exit 1
else
    issueId=$1
fi

#get the current branch
curBranch=$(git branch | sed -n '/\* /s///p')
if [ $curBranch = $masterBase ] 
then
    nxtBranch=$branchBase
    nxtTrack=$branchBase
    curTrack=$masterBase
elif [ $curBranch = $branchBase ]
then
    nxtBranch=$masterBase
    nxtTrack=$masterBase
    curTrack=$branchBase
else
    echo "Please make sure that you are in either $masterBase or $branchBase"
    exit 1
fi

curBranchExtend="$curBranch-iss$issueId"
nxtBranchExtend="$nxtBranch-iss$issueId"
masterBranchExtend="$masterBase-iss$issueId"
branchBranchExtend="$branchBase-iss$issueId"
echo "you are at $curBranch going to create $curBranchExtend"

#commit current modify
#commitLabel=$(curl --silent -u "$uid:$password" $apiIssueBaseUrl+$issueId \
#    | sed -n '/title/s/\"title\"://p' | sed -n 's/[\",]//gp' | head -n1)
if [ -z "$2" ]
then
    echo Usage: push.sh issueNumber CommitInfo
    exit 1
else
    commitLabel=$2
fi

if [ ! -z "$commitLabel" ]
then
    echo "Commit Message":$commitLabel
    if git commit -am "[FIX]$commitLabel"
    then
        commitNumber=$(git log -n1 --pretty=format:"%H")
        echo Commit Hash Number:$commitNumber
    fi
else
    echo cannot get issue info, return
    exit 1
fi

#do push for current branch
git checkout -b $curBranchExtend

if git pull --rebase $remoteOrigin $curTrack
then
    git push $remoteMy $curBranchExtend
    echo "Seccuessful Push Commit to $curBranchExtend"
else
    exit 1;
fi

#do push for nxt branch
git checkout $nxtBranch
git checkout -b $nxtBranchExtend
if { git pull --rebase $remoteOrigin $nxtTrack; git cherry-pick $commitNumber; }
then
    git push $remoteMy $nxtBranchExtend
    echo "Seccuessful Push Commit to $nxtBranchExtend"
else
    exit 1
fi

#remove the commit in current branch
git checkout $curBranch
