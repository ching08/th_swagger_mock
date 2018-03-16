## To rebuild images
## docker login hub.gitlab-sj.thalesesec.com ( with your access token)
## docker build -t run_mock .
## # commit image
## docker tag run_mock hub.gitlab-sj.thalesesec.com/lucy/mock_example/run_mock:latest
## docker push hub.gitlab-sj.thalesesec.com/lucy/mock_example/run_mock:latest .


## docker build -t ARG name=defaultValue
FROM registry.opensource.zalan.do/stups/python:3.5.2-38

WORKDIR /data

COPY requirements.txt /
COPY run_mock.sh /

RUN pip3 install -r /requirements.txt
RUN pip3 install --upgrade pip


EXPOSE 8080


ENTRYPOINT ["/run_mock.sh" ]
CMD [ "static" ]
