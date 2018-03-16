
if [ -z $POSTMAN_HOST ] ; then
    echo "ERROR ! Please define env vars POSTMAN_HOST=<ip>:<port>"
    exit 1
else
    echo "HOST: $POSTMAN_HOST"
fi
 

rm -rf reports newman
cmd="newman run --global-var \"host=$POSTMAN_HOST\" --reporters html test/rds.postman_collection.json"
echo $cmd
eval $cmd
res=$?
echo "exit with $res"
mv newman  reports
echo "============================="
echo "html report location : $(pwd)/reports"
echo "============================="
exit $res

