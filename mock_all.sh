

function usage {
    echo "Usage: $0 <path to all repo> <base_port>"
    echo "Usage: $0 clean" 

}


if [ -z $1 ]; then
    echo  "ERROR!!! please provide root path"
    usage
    exit 1
fi

rm -f /tmp/lucy_mocks.txt || true
rm -f /tmp/repo_list.txt || true
curl -H "PRIVATE-TOKEN:eN6zJz2YeFHkH2iBhYwD" https://git.gitlab-sj.thalesesec.com/api/v4/projects/achang%2FLucy-api/repository/files/repo_list%2Etxt/raw?ref=master -o /tmp/repo_list.txt
lucy_services=$(cat /tmp/repo_list.txt)
echo "Lucy services: $lucy_services"


if [ "$1" == "clean" ] ; then
    for service in $lucy_services
    do
	echo "kill $service mock"
	docker rm -f $service || true
	sleep 1s
    done
    exit 0
fi 


root=$(realpath $1)
port=$2

if  [ ! -d $root ] ; then
    mkdir -p $root
fi 


if [ -z $port ] ; then
    echo "Please provide base port"
    usage
    exit 1
fi 



output=""
for service in $lucy_services
do
    path=$root/$service
    if [ ! -d $path ]; then
	echo "$path does not exist, going to clone it"
	git clone git@git.gitlab-sj.thalesesec.com:lucy/$service.git $path
	cd $path
    else
	echo "$path exists. update it "
	cd $path
	git checkout master
	git pull origin master
	
	
	
    fi 
    echo ""
    echo "=================================================="
    echo "Start static Mocking '$service:$port' from $path ..."
    if  [ ! -d $path ] ; then
	echo "ERROR !!!! Path $path does not exist"
	exit 1
	
    fi 

    docker rm -f $service || true
    docker run -d  --name $service -p $port:8080 -v $(pwd):/data hub.gitlab-sj.thalesesec.com/lucy/mock_example/run_mock:latest static
    sleep 2s
    docker ps -f name=$service
    if [ -f ${path}/swagger.yaml ] ;then
	basePath=$(fgrep "basePath:" ${path}/swagger.yaml | awk '{print $2}')
    else
	basePath=$(fgrep "basePath:" ${path}/swagger.yml | awk '{print $2}')
    fi
    basePath=${basePath%/}
    basePath=$(echo $basePath | sed 's/^\///')
    ip=$(hostname -I | awk '{print $1}')
    url="http://${ip}:${port}/${basePath}/ui"
    printf "%-25s: %s\n" ${service} $url >>  /tmp/lucy_mocks.txt
    port=$((port + 1))

done
echo ""
echo "------------------------------------"
echo "Done"
echo "------------------------------------"
cat /tmp/lucy_mocks.txt



