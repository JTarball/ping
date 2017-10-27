package main

import (
	"log"
	"net"

	"golang.org/x/net/context"
	"google.golang.org/grpc"
  "github.com/newtonsystems/grpc_types/go/grpc_types"
	"google.golang.org/grpc/reflection"
)

const (
	port = ":50000"
)

type server struct{}

// Ping responses with a message back and
func (s *server) Ping(ctx context.Context, in *grpc_types.PingRequest) (*grpc_types.PingResponse, error) {
  logger.Log("level", "info", "method", "Ping", "msg", "Received ping from service: "+ in.Name)
	return &grpc_types.PingResponse{Message: "Hello " + in.Name}, nil
}

func main() {
  // -- Setup logging
  // Color by level value
	colorFn := func(keyvals ...interface{}) term.FgBgColor {
		for i := 0; i < len(keyvals)-1; i += 2 {
			if keyvals[i] != "level" {
				continue
			}
			switch keyvals[i+1] {
			case "debug":
				return term.FgBgColor{Fg: term.DarkGray}
			case "info":
				return term.FgBgColor{Fg: term.DarkGreen}
			case "warn":
				return term.FgBgColor{Fg: term.Yellow, Bg: term.White}
			case "error":
				return term.FgBgColor{Fg: term.Red}
			case "crit":
				return term.FgBgColor{Fg: term.Gray, Bg: term.DarkRed}
			default:
				return term.FgBgColor{}
			}
		}
		return term.FgBgColor{}
	}

	// Logging domain.
	var logger log.Logger
	{
		logger = term.NewLogger(os.Stdout, log.NewLogfmtLogger, colorFn)
		logger = log.With(logger, "ts", log.DefaultTimestampUTC)
		logger = log.With(logger, "caller", log.DefaultCaller)
		logger = log.With(logger, "service", "ping")
	}

  logger.Log("level", "info", "msg", "starting ...")
	defer logger.Log("msg", "goodbye")

  // ---------------------------------------------------------------------------

  // Listen on port
	lis, err := net.Listen("tcp", port)
	if err != nil {
		logger.Log("level", "error", "msg","Failed to listen on port %s: %v", port, err)
    return
	}
  defer lis.Close()

  // Setup gRPC
	s := grpc.NewServer()
	pb.RegisterPingServer(s, &server{})
  defer s.GracefulStop()

	// Register reflection service on gRPC server.
	reflection.Register(s)

  // Serve
	if err := s.Serve(lis); err != nil {
		logger.Log("level", "error", "msg", "Failed to serve on port %s : %v", port, err)
    return
	}

}
