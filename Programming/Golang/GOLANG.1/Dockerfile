FROM golang:1.16.6-buster

ENV APP_NAME web
ENV PORT 8080

WORKDIR /workspace

#COPY . /go/src/${APP_NAME}
#WORKDIR /go/src/${APP_NAME}

# RUN go mod init
RUN go build -o ${APP_NAME}

RUN mkdir /app
RUN cp /workspace/web /app 

WORKDIR /app      
CMD ./${APP_NAME}

EXPOSE ${PORT}
