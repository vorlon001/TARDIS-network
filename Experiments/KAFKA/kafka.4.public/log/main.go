package main

import (
	"context"
	"log"
	"math/rand"
	"os"
	"fmt"
	"time"
	"strconv"
	"strings"
	"github.com/segmentio/kafka-go"
)

func makeGroupID() string {
	return fmt.Sprintf("kafka-go-group-%016x", rand.Int63())
}

func main() {
	log.SetOutput(os.Stdout)

	// kafka topic
	topic := os.Getenv("kafkaTopik")

	partition, err := strconv.Atoi(os.Getenv("kafkaPartition"))
	if err != nil {
		panic(err)
	}
	kafkaBroker := strings.Split(os.Getenv("kafkaBroker"), ",")


	log.Printf("topic:%v\n", topic)
	log.Printf("partition:%v\n", partition)
	log.Printf("kafkaBroker:%v\n", kafkaBroker)

	// create kafka connection
	r := kafka.NewReader(kafka.ReaderConfig{
		Brokers:   kafkaBroker,
		Topic:             topic,
		HeartbeatInterval: 2 * time.Second,
		CommitInterval:    2 * time.Second,
		RebalanceTimeout:  2 * time.Second,
		RetentionTime:     time.Hour,
		MinBytes:          1,
		MaxBytes:          1e6,
		Partition: partition,
		QueueCapacity: 1000,
	})

        defer func() {
                if err := r.Close(); err != nil {
                        log.Print("failed to close reader", "error", err)
                }
        }()

	for {
		// read message from kafka
		m, err := r.ReadMessage(context.Background())
		if err != nil {
			log.Println(err)
			break
		}

                log.Printf("partition: %v, Offset:%v Key:%v Value:%v\n", partition, m.Offset, string(m.Key), string(m.Value))
                log.Printf("partition: %v, %#v\n", partition, m)

	}
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
