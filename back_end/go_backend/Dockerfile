FROM golang:1.22

WORKDIR /go/src/app

COPY . .

RUN go build -o main main.go

EXPOSE 8080

CMD ["./main"]
