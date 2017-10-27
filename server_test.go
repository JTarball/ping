package main

import (
	"context"
	"fmt"
	"net"
	"testing"
	"testing/quick"

	"github.com/newtonsystems/agent-mgmt/app/tests"
	"github.com/newtonsystems/grpc_types/go/grpc_types"
	"google.golang.org/grpc"
)

// TestPingMessage tests response back from Ping method
func TestPingSaneMessage(t *testing.T) {
	// Check port
	ln, errLn := net.Listen("tcp", grpcPort)
	if errLn != nil {
		t.Error(errLn)
		t.FailNow()
	}

	// Connection to grpc server
	s := grpc.NewServer()
	grpc_types.RegisterPingServer(s, &Server{})
	go s.Serve(ln)
	defer s.GracefulStop()

	// Connect via client
	conn, errDial := grpc.Dial(grpcPort, grpc.WithInsecure())
	defer conn.Close()
	if errDial != nil {
		t.Fatalf("unable to Dial: %+v", errDial)
		t.FailNow()
	}

	client := grpc_types.NewPingClient(conn)

	assertion := func(message string) bool {
		fmt.Printf("Running 'TestPingSaneMessage' assert check: (message=%s)\n", message)

		resp, err := client.Ping(
			context.Background(),
			&grpc_types.PingRequest{Message: message},
		)
		tests.Ok(t, err)

		return ("Hello " + message) == resp.Message
	}

	err := quick.Check(assertion, nil)
	tests.Ok(t, err)

}
