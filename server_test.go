package main_test

import (
	"log"
	"net"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
  "github.com/newtonsystems/grpc_types/go/grpc_types"
	"google.golang.org/grpc/reflection"
)

type server struct{}

const (
	port = ":50000"
)

// TestPingMessage tests response back from Ping method
func TestPingMessage(t *testing.T) {
  // Check port
  ln, err := net.Listen("tcp", hostPort)
  if err != nil {
    t.Error(err)
    t.FailNow()
  }

  // Connection to grpc server
  s := grpc.NewServer()
	pb.RegisterPingServer(s, &server{})
  defer s.GracefulStop()
  go s.Serve(ln)
  defer s.GracefulStop()

  // Connect via client
  conn, err := grpc.Dial(hostPort, grpc.WithInsecure())
  defer conn.Close()
  if err != nil {
    t.Fatalf("unable to Dial: %+v", err)
    t.FailNow()
  }

  client := grpc_types.NewPingClient(conn)


	assertion := func(message string) bool {
		fmt.Printf("Running 'TestPingMessage' assert check: (message=%s)\n", message)

    resp, err := client.Ping(
      context.Background(),
      &grpc_types.PingRequest{},
    )
		tests.Ok(t, err)

		return ("Hello " + message) == resp.Message
	}

	err := quick.Check(assertion, nil)
	tests.Ok(t, err)

}
