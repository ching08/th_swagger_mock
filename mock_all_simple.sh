

root="/home/annie/VMShare/projects"
 
service=inventory-service
docker run -d  --name $service -p 9000:8080 -v ${root}/$service:/data hub.gitlab-sj.thalesesec.com/lucy/mock_example/run_mock:latest static


service=credentials-service
docker run -d  --name $service -p 9001:8080 -v ${root}/$service:/data hub.gitlab-sj.thalesesec.com/lucy/mock_example/run_mock:latest static


service=rule-service
docker run -d  --name $service -p 9002:8080 -v ${root}/$service:/data hub.gitlab-sj.thalesesec.com/lucy/mock_example/run_mock:latest static


service=user-management-service
docker run -d  --name $service -p 9003:8080 -v ${root}/$service:/data hub.gitlab-sj.thalesesec.com/lucy/mock_example/run_mock:latest static


docker ps




