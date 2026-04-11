FROM golang:1.25-alpine AS build
WORKDIR /app
COPY shared/ ./shared/
COPY proto/ ./proto/
COPY quiz-service/ ./quiz-service/
WORKDIR /app/quiz-service
RUN go mod download && CGO_ENABLED=0 go build -o /service .

FROM alpine:3.20
COPY --from=build /service /service
ENTRYPOINT ["/service"]
