package main

import (
	"log"
	"math/rand"
	"net/http"
	"os"
	"time"
	"strconv"
	"strings"
	"fmt"
	"github.com/segmentio/kafka-go"
)

func makeKeyID() string {
        return fmt.Sprintf("kafka-go-group-%016x", rand.Int63())
}

func getKafkaWriter(kafkaBroker []string, topic string) *kafka.Writer {
        return  kafka.NewWriter(kafka.WriterConfig{
                Brokers:   kafkaBroker,
                Topic:     topic,
		BatchBytes: 1024000,
		BatchSize: 1000,
		Async: true,
		BatchTimeout: 50 * time.Millisecond,
		Balancer: &kafka.RoundRobin{},
        })
}

func producerHandler(kafkaWriter *kafka.Writer) func(http.ResponseWriter, *http.Request) {
	return http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {

		msg := kafka.Message{
			Key:   []byte( makeKeyID()),
			Value:   []byte(fmt.Sprintf("address-%s", request.RemoteAddr)),
		}
		err := kafkaWriter.WriteMessages(request.Context(), msg)

		if err != nil {
			writer.Write([]byte(err.Error()))
			log.Fatalln(err)
		}

		log.Print(string(msg.Key), string(msg.Value))

                writer.Header().Add("Content-Type", "application/json")
                writer.Write([]byte("done!"))

	})
}

func main() {
	log.SetOutput(os.Stdout)

        topic := os.Getenv("kafkaTopik")

        partition, err := strconv.Atoi(os.Getenv("kafkaPartition"))
        if err != nil {
                panic(err)
        }

        kafkaBroker := strings.Split(os.Getenv("kafkaBroker"), ",")


        log.Printf("topic:%v\n", topic)
        log.Printf("partition:%v\n", partition)
        log.Printf("kafkaBroker:%v\n", kafkaBroker)


	kafkaWriter := getKafkaWriter(kafkaBroker, topic)

	defer kafkaWriter.Close()

	// Add handle func for producer.
	http.HandleFunc("/handle", producerHandler(kafkaWriter))

	// Run the web server.
	fmt.Println("start producer-api ... !!")
	log.Fatal(http.ListenAndServe(":8890", nil))

}

var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

// Random string generator
func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}
