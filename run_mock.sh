#! /bin/bash



GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color
title() {
    printf "${BLUE}${1}${NC}\n"
}

green() {
    printf "${GREEN}${1}${NC}\n"
}

error() {
    printf "${RED}ERROR:${1}${NC}\n"
}


show_help() {
    echo "show_help"
}


pre_pare_repo_source() {
    
    service_repo="/data"
    tmpDir="/data1"
    if [ -d $tmpdir ] ; then
	rm -rf  $tmpDir 
    fi
    mkdir $tmpDir
    echo "mock directory : $tmpDir"
    cp -rf $service_repo/swagger.yaml $tmpDir
    cp $(find $service_repo/mock_connexion/ | egrep -v '(Dockerfile|mock_connexion/$|\.venv|__pycache|.gitignore)') $tmpDir || true


    if [ ! -f "$tmpDir/swagger.yaml" ] ; then
	error "$tmpDir/swagger.yaml not exists."
	exit 1
    fi
    ## remove host str
    sed -r -i  's/host\:.*//1g' $tmpDir/swagger.yaml  || true

    ## check dynamic mode
    if [ "$mock_mode" = "dynamic" ] ; then
	if [ ! -f "$tmpDir/app.py" ]; then
	    error "$tmpDir/app.py does not exists. please create it or use remote repo"
	    exit 1
	fi
    fi
}


start_connexion_mock() {
    cd $tmpDir
    #ls -l $tmpDir
    ## start container
    #dockerReg="hub.gitlab-sj.thalesesec.com/lucy/mock_example/connexion:latest"
    #cmd="docker run --name $service_name -d -p ${port}:8080 -v ${tmpDir}:/data $dockerReg"
    cmd="connexion run -p 8080 --host 0.0.0.0 --verbose swagger.yaml"
    if [ $mock_mode = "static" ]; then
	cmd="$cmd --mock=all"
    fi
    title "$cmd"
    eval $cmd
}

get_baseUrl() {
    baseUrl=`cat $tmpDir/swagger.yaml | grep -e "basePath:"| cut -d ":" -f 2| tr -d ' '`
    echo $get_baseUrl
    baseUrl=`echo $baseUrl | sed -e 's/\/$//'`
    if [ $? != 0 ]; then
	error "Warning: Can't not parse baseUrl from $tmpDir/swagger.yaml!"
    fi
}

test_mock() {

    # this will be enabled after all server support status
    url="http://0.0.0.0:${port}${baseUrl}/status"
    #url="http://0.0.0.0:${port}${baseUrl}/ui"
    cmd="curl --fail $url"
    title "Testing mock server $service_name: $url"
    set +e
    eval $cmd
    if [ $? != 0 ] ; then
	error "HTTP GET $url FAILED !!!"
	test_code=1
    else
	green "HTTP GET $url PASSED !!!"
	test_code=0
    fi
}

####################


mock_mode=$1
if [ "${mock_mode}x" = "x" ] ; then
    mock_mode="static"
fi


pattern="^(static|dynamic)$"
if [[ ! ${mock_mode} =~ $pattern ]]; then
    error "Unsupported mock type '$mock_mode', only allow 'static'or 'dynamic'"
    show_help; exit 1
fi



pre_pare_repo_source
if [ -f $tmpDir/requirements.txt ]; then
    pip3 install -r $tmpDir/requirements.txt
fi
get_baseUrl
title "Mock Sever UI : http://0.0.0.0:8080${baseUrl}/ui"
start_connexion_mock
#test_mock
